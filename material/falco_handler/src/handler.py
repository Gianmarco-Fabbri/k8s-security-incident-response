from flask import Flask, request
import subprocess
import re

app = Flask(__name__)

@app.route("/", methods=["POST"])
def webhook():
    data = request.get_json()
    pod = data.get("output_fields", {}).get("k8s.pod.name")
    namespace = data.get("output_fields", {}).get("k8s.ns.name")
    
    # Extract pod and namespace from container name if not found
    if not pod or not namespace:
        container_full_name = str(data.get("output_fields", {}).get("container.name") or "")
        match = re.match(r"k8s_([^_]+)_([^_]+)_([^_]+)_", container_full_name)
        if match:
            container_name, pod, namespace = match.groups()
    
    app.logger.info(f"[*] Triggered rule from pod={pod}, ns={namespace}")
    app.logger.info(f"[*] Full data: {data}")

    if pod and namespace:
        try:
            # Get owner's kind and name in a single kubectl call
            result = subprocess.run(
                ["kubectl", "get", "pod", pod, "-n", namespace,
                 "-o", "jsonpath={.metadata.ownerReferences[0].kind},{.metadata.ownerReferences[0].name}"],
                stdout=subprocess.PIPE, check=True, text=True
            )
            owner_info = result.stdout.strip().split(',')
            deployment = ""
            if len(owner_info) == 2:
                owner_kind, owner_name = owner_info
                if owner_kind == "ReplicaSet":
                    # Query the ReplicaSet to get the Deployment owner name
                    rs_result = subprocess.run(
                        ["kubectl", "get", "replicaset", owner_name, "-n", namespace,
                         "-o", "jsonpath={.metadata.ownerReferences[0].name}"],
                        stdout=subprocess.PIPE, check=True, text=True
                    )
                    deployment = rs_result.stdout.strip()
                else:
                    deployment = owner_name
            app.logger.info(f"[*] Resolved owner kind={owner_info[0] if len(owner_info) > 0 else 'None'} name={owner_info[1] if len(owner_info) > 1 else 'None'}")
            app.logger.info(f"[*] Resolved Deployment name: {deployment}")
            if deployment:
                subprocess.run([
                    "kubectl", "label", "deployment", deployment,
                    "tainted-by-falco=true", "-n", namespace, "--overwrite"
                ], check=True)
                app.logger.info(f"[+] Labeled deployment {deployment} in {namespace}")

                # SCALE REPLICAS TO 0 OR DO WHATEVER ACTION YOU WANT
                #subprocess.run([
                #    "kubectl", "scale", "deployment", deployment, "--replicas=0", "-n", namespace
                #], check=True)
                #app.logger.info(f"[+] Action on deployment {deployment} in {namespace}")
                
        except subprocess.CalledProcessError as e:
            app.logger.error(f"[-] Error labeling deployment: {e}")
    else:
        app.logger.warning("[!] Could not resolve pod or namespace")
    return "ok", 200

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000)