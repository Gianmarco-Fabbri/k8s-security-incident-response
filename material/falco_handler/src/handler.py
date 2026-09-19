"""Authenticated Falco webhook that quarantines explicitly allowed lab workloads."""

from dataclasses import dataclass
from datetime import datetime, timezone
import hmac
import logging
import os
import re
import threading
from typing import Mapping, Optional, Set

from flask import Flask, jsonify, request
from kubernetes import client, config
from kubernetes.client.rest import ApiException


DEFAULT_ALLOWED_RULES = (
    "Redirect STDOUT/STDIN to Network Connection in Container,"
    "PTRACE anti-debug attempt,"
    "Detect Network Tools in vulnapp"
)
MANAGER_LABEL = "security-lab/managed-by"
MANAGER = "falco-handler"
QUARANTINED_AT = "security-lab/quarantined-at"
EVIDENCE_EXPORTED = "security-lab/evidence-exported"


def _csv_set(value: str) -> Set[str]:
    return {item.strip() for item in value.split(",") if item.strip()}


@dataclass(frozen=True)
class Settings:
    webhook_token: str
    allowed_rules: Set[str]
    allowed_namespaces: Set[str]
    target_label_key: str
    target_label_value: str
    detach_label_keys: Set[str]
    max_quarantined_pods: int
    request_timeout_seconds: float
    pod_name: str
    pod_namespace: str

    @classmethod
    def from_environ(cls, environ: Mapping[str, str]) -> "Settings":
        token = environ.get("WEBHOOK_TOKEN", "").strip()
        if not token or token == "CHANGE_ME":
            raise RuntimeError("WEBHOOK_TOKEN must be configured; refusing to start unauthenticated")

        max_quarantined = int(environ.get("MAX_QUARANTINED_PODS", "3"))
        if max_quarantined < 1:
            raise ValueError("MAX_QUARANTINED_PODS must be at least 1")
        timeout = float(environ.get("K8S_REQUEST_TIMEOUT_SECONDS", "3"))
        if not 0 < timeout <= 10:
            raise ValueError("K8S_REQUEST_TIMEOUT_SECONDS must be in (0, 10]")

        return cls(
            webhook_token=token,
            allowed_rules=_csv_set(environ.get("ALLOWED_RULES", DEFAULT_ALLOWED_RULES)),
            allowed_namespaces=_csv_set(environ.get("ALLOWED_NAMESPACES", "default")),
            target_label_key=environ.get("TARGET_LABEL_KEY", "app").strip(),
            target_label_value=environ.get("TARGET_LABEL_VALUE", "vulnapp").strip(),
            detach_label_keys=_csv_set(
                environ.get("DETACH_LABEL_KEYS", "app,pod-template-hash")
            ),
            max_quarantined_pods=max_quarantined,
            request_timeout_seconds=timeout,
            pod_name=environ.get("POD_NAME", "").strip(),
            pod_namespace=environ.get("POD_NAMESPACE", "default").strip(),
        )


def _resolve_workload(data: dict) -> tuple[Optional[str], Optional[str]]:
    output_fields = data.get("output_fields")
    if not isinstance(output_fields, dict):
        return None, None

    pod = output_fields.get("k8s.pod.name")
    namespace = output_fields.get("k8s.ns.name")
    if pod and namespace:
        return str(pod), str(namespace)

    # CRI fallback: k8s_<container>_<pod>_<namespace>_<uid>_<restart>
    container_full_name = str(output_fields.get("container.name") or "")
    match = re.match(r"k8s_([^_]+)_([^_]+)_([^_]+)_", container_full_name)
    if not match:
        return None, None

    _, pod, namespace = match.groups()
    return pod, namespace


def _quarantine_time(pod: object):
    value = (getattr(pod.metadata, "annotations", None) or {}).get(QUARANTINED_AT)
    try:
        timestamp = datetime.fromisoformat(value.replace("Z", "+00:00"))
        return timestamp if timestamp.tzinfo else None
    except (AttributeError, ValueError, TypeError):
        return None


def create_app(
    k8s_api: Optional[client.CoreV1Api] = None,
    environ: Optional[Mapping[str, str]] = None,
) -> Flask:
    """Application factory; dependency injection keeps the response logic testable."""
    settings = Settings.from_environ(os.environ if environ is None else environ)
    app = Flask(__name__)
    app.config["MAX_CONTENT_LENGTH"] = 64 * 1024
    response_lock = threading.Lock()

    gunicorn_logger = logging.getLogger("gunicorn.error")
    if gunicorn_logger.handlers:
        app.logger.handlers = gunicorn_logger.handlers
        app.logger.setLevel(gunicorn_logger.level)

    if k8s_api is None:
        config.load_incluster_config()
        k8s_api = client.CoreV1Api()
        app.logger.info("Authenticated with the Kubernetes API")

    @app.get("/health")
    def health() -> tuple[str, int]:
        return "ok", 200

    @app.get("/ready")
    def ready():
        if not settings.pod_name:
            return jsonify(status="not-ready", reason="POD_NAME is not configured"), 503
        try:
            k8s_api.read_namespaced_pod(
                name=settings.pod_name,
                namespace=settings.pod_namespace,
                _request_timeout=settings.request_timeout_seconds,
            )
            return jsonify(status="ready"), 200
        except Exception as exc:
            app.logger.warning("Kubernetes readiness check failed: %s", exc)
            return jsonify(status="not-ready"), 503

    @app.post("/")
    def webhook():
        supplied_token = request.headers.get("X-Falco-Token", "")
        if not hmac.compare_digest(supplied_token.encode(), settings.webhook_token.encode()):
            app.logger.warning("Rejected webhook with invalid authentication")
            return jsonify(error="unauthorized"), 401

        data = request.get_json(silent=True)
        if not isinstance(data, dict):
            return jsonify(error="invalid JSON payload"), 400

        rule = str(data.get("rule") or "")
        source = str(data.get("source") or "")
        if source != "syscall" or rule not in settings.allowed_rules:
            app.logger.info("Ignored Falco event source=%s rule=%s", source, rule)
            return jsonify(status="ignored"), 202

        pod, namespace = _resolve_workload(data)
        if not pod or not namespace:
            return jsonify(error="pod identity is missing"), 400
        if namespace not in settings.allowed_namespaces:
            app.logger.warning("Rejected event for namespace=%s", namespace)
            return jsonify(error="namespace is not allowed"), 403

        app.logger.info(
            "Accepted Falco rule=%s priority=%s pod=%s namespace=%s",
            rule,
            data.get("priority"),
            pod,
            namespace,
        )

        if not response_lock.acquire(blocking=False):
            return jsonify(error="response in progress; retry"), 503
        try:
            target_pod = k8s_api.read_namespaced_pod(
                name=pod,
                namespace=namespace,
                _request_timeout=settings.request_timeout_seconds,
            )
            existing_labels = target_pod.metadata.labels or {}
            already_quarantined = existing_labels.get("tainted-by-falco") == "true"
            if already_quarantined and existing_labels.get(MANAGER_LABEL) != MANAGER:
                return jsonify(error="quarantine is not managed by this handler"), 403

            if not already_quarantined and existing_labels.get(settings.target_label_key) != settings.target_label_value:
                app.logger.warning("Rejected event for non-target pod=%s", pod)
                return jsonify(error="pod is outside the managed workload"), 403

            # Preserve unrelated metadata. Only selector labels required to detach the
            # lab workload are removed, and resourceVersion provides conflict detection.
            patch_labels = {
                key: None for key in settings.detach_label_keys if key in existing_labels
            }
            patch_labels["tainted-by-falco"] = "true"
            patch_labels[MANAGER_LABEL] = MANAGER
            patch = {
                "metadata": {
                    "resourceVersion": target_pod.metadata.resource_version,
                    "labels": patch_labels,
                    "annotations": {QUARANTINED_AT: datetime.now(timezone.utc).isoformat()},
                }
            }
            patched_pod = target_pod if already_quarantined else k8s_api.patch_namespaced_pod(
                name=pod,
                namespace=namespace,
                body=patch,
                _request_timeout=settings.request_timeout_seconds,
            )
            if (patched_pod.metadata.labels or {}).get("tainted-by-falco") != "true":
                raise RuntimeError("Kubernetes API response did not confirm quarantine label")

            # Cleanup happens only after successful containment. Retain a bounded set
            # of recent forensic pods instead of destroying the previous evidence first.
            quarantined = k8s_api.list_namespaced_pod(
                namespace=namespace,
                label_selector=f"tainted-by-falco=true,{MANAGER_LABEL}={MANAGER}",
                _request_timeout=settings.request_timeout_seconds,
            )
            previous = [item for item in quarantined.items
                        if item.metadata.name != pod
                        and (item.metadata.labels or {}).get(MANAGER_LABEL) == MANAGER
                        and (item.metadata.labels or {}).get("tainted-by-falco") == "true"
                        and _quarantine_time(item) is not None]
            previous.sort(key=_quarantine_time, reverse=True)
            keep_previous = settings.max_quarantined_pods - 1
            cleanup_pending = False
            for stale_pod in previous[keep_previous:]:
                # Never destroy unexported evidence automatically. This is a soft
                # retention target, not a hard resource cap or a forensic exporter.
                if (getattr(stale_pod.metadata, "annotations", None) or {}).get(EVIDENCE_EXPORTED) != "true":
                    app.logger.warning("Retaining unexported evidence pod=%s", stale_pod.metadata.name)
                    continue
                try:
                    k8s_api.delete_namespaced_pod(
                        name=stale_pod.metadata.name,
                        namespace=namespace,
                        body=client.V1DeleteOptions(
                            grace_period_seconds=30,
                            preconditions=client.V1Preconditions(
                                uid=stale_pod.metadata.uid,
                                resource_version=stale_pod.metadata.resource_version),
                        ),
                        _request_timeout=settings.request_timeout_seconds,
                    )
                    app.logger.info("Deleted expired forensic pod=%s", stale_pod.metadata.name)
                except ApiException as exc:
                    if exc.status == 404:
                        continue
                    cleanup_pending = True
                    app.logger.error(
                        "Quarantine succeeded but retention cleanup failed for pod=%s: %s",
                        stale_pod.metadata.name,
                        exc,
                    )

            if cleanup_pending:
                return jsonify(status="quarantined", cleanup="retry-required"), 503
            app.logger.info("Quarantine label confirmed pod=%s namespace=%s", pod, namespace)
            return jsonify(status="already-quarantined" if already_quarantined else "quarantined",
                           pod=pod, namespace=namespace), 200
        except ApiException as exc:
            app.logger.error("Kubernetes API error while quarantining pod=%s: %s", pod, exc)
            return jsonify(error="Kubernetes API request failed"), 502
        except Exception as exc:
            app.logger.exception("Unexpected quarantine error for pod=%s: %s", pod, exc)
            return jsonify(error="quarantine failed"), 500
        finally:
            response_lock.release()

    return app
