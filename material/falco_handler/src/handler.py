from flask import Flask, request, jsonify
from kubernetes import client, config
from kubernetes.client.rest import ApiException
import re
import logging
import sys

app = Flask(__name__)
# Configure logging for gunicorn
gunicorn_logger = logging.getLogger('gunicorn.error')
app.logger.handlers = gunicorn_logger.handlers
app.logger.setLevel(gunicorn_logger.level)

# Initialize Kubernetes client
try:
    config.load_incluster_config()
    k8s_core_v1 = client.CoreV1Api()
    app.logger.info("Successfully authenticated with Kubernetes API.")
except config.ConfigException:
    app.logger.error("FATAL: Not running inside a Kubernetes cluster, or missing service account.")
    sys.exit(1)

@app.route("/health", methods=["GET"])
def healthz():
    return "ok", 200

@app.route("/", methods=["POST"])
def webhook():
    try:
        data = request.get_json(silent=True) or {}
        output_fields = data.get("output_fields")
        if not isinstance(output_fields, dict):
            app.logger.warning("[!] Invalid payload: output_fields is not a dictionary")
            return "Bad Request: Invalid payload", 400
            
        pod = output_fields.get("k8s.pod.name")
        namespace = output_fields.get("k8s.ns.name")
        
        if not pod or not namespace:
            container_full_name = str(output_fields.get("container.name") or "")
            match = re.match(r"k8s_([^_]+)_([^_]+)_([^_]+)_", container_full_name)
            if match:
                container_name, pod, namespace = match.groups()
        
        app.logger.info(f"[*] Triggered rule from pod={pod}, ns={namespace}")
    except Exception as e:
        app.logger.error(f"[!] Error parsing payload: {e}")
        return "Internal Server Error", 500

    if pod and namespace:
        try:
            # 1. Idempotency: Check if the targeted pod is already quarantined
            target_pod = k8s_core_v1.read_namespaced_pod(name=pod, namespace=namespace)
            existing_labels = target_pod.metadata.labels or {}
            
            if existing_labels.get("tainted-by-falco") == "true":
                app.logger.info(f"[*] Pod {pod} is already quarantined. Ignoring duplicate alert.")
                return "ok", 200

            # 2. DoS Prevention Limit: delete ONLY older quarantined pods
            quarantined_pods = k8s_core_v1.list_namespaced_pod(
                namespace=namespace,
                label_selector="tainted-by-falco=true"
            )
            for q_pod in quarantined_pods.items:
                if q_pod.metadata.name != pod:
                    app.logger.info(f"[*] Deleting old quarantined pod: {q_pod.metadata.name} to prevent DoS")
                    k8s_core_v1.delete_namespaced_pod(
                        name=q_pod.metadata.name,
                        namespace=namespace,
                        body=client.V1DeleteOptions(grace_period_seconds=0)
                    )

            # 3. Dynamically detach the pod from its ReplicaSet
            # Construct a Strategic Merge Patch where we set all existing label keys to None (null)
            # to explicitly instruct Kubernetes to delete them, then add our taint label.
            patch_labels = {k: None for k in existing_labels.keys()}
            patch_labels["tainted-by-falco"] = "true"
            
            patch = {
                "metadata": {
                    "labels": patch_labels
                }
            }
            k8s_core_v1.patch_namespaced_pod(
                name=pod,
                namespace=namespace,
                body=patch
            )
            app.logger.info(f"[+] Quarantined pod {pod} in {namespace}")
            return "ok", 200
            
        except ApiException as e:
            app.logger.error(f"[-] Kubernetes API error: {e}")
            return "Internal Server Error", 500
        except Exception as e:
            app.logger.error(f"[-] Unexpected error: {e}")
            return "Internal Server Error", 500
    else:
        app.logger.warning("[!] Could not resolve pod or namespace")
        return "Bad Request", 400