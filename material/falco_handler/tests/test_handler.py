import unittest
from types import SimpleNamespace

from kubernetes.client.rest import ApiException

from handler import create_app, MANAGER_LABEL, MANAGER, QUARANTINED_AT, EVIDENCE_EXPORTED


def pod(name, labels, created="2026-01-01T00:00:00Z", uid=None):
    return SimpleNamespace(
        metadata=SimpleNamespace(
            name=name,
            namespace="default",
            labels=dict(labels),
            resource_version="7",
            uid=uid or f"uid-{name}",
            creation_timestamp=created,
            annotations={QUARANTINED_AT: created, EVIDENCE_EXPORTED: "true"},
        )
    )


class FakeCoreV1Api:
    def __init__(self, target, quarantined=None, patch_error=None):
        self.target = target
        self.quarantined = list(quarantined or [])
        self.patch_error = patch_error
        self.calls = []

    def read_namespaced_pod(self, name, namespace, **kwargs):
        self.calls.append(("read", name))
        return self.target

    def patch_namespaced_pod(self, name, namespace, body, **kwargs):
        self.calls.append(("patch", name, body))
        if self.patch_error:
            raise self.patch_error
        for key, value in body["metadata"]["labels"].items():
            if value is None:
                self.target.metadata.labels.pop(key, None)
            else:
                self.target.metadata.labels[key] = value
        self.target.metadata.annotations.update(body["metadata"].get("annotations", {}))
        return self.target

    def list_namespaced_pod(self, namespace, label_selector, **kwargs):
        self.calls.append(("list", namespace))
        return SimpleNamespace(items=self.quarantined + [self.target])

    def delete_namespaced_pod(self, name, namespace, body, **kwargs):
        self.calls.append(("delete", name))


class HandlerTests(unittest.TestCase):
    def setUp(self):
        self.environ = {
            "WEBHOOK_TOKEN": "test-secret",
            "ALLOWED_RULES": "Rule A",
            "ALLOWED_NAMESPACES": "default",
            "TARGET_LABEL_KEY": "app",
            "TARGET_LABEL_VALUE": "vulnapp",
            "DETACH_LABEL_KEYS": "app,pod-template-hash",
            "MAX_QUARANTINED_PODS": "1",
            "POD_NAME": "falco-handler-test",
            "POD_NAMESPACE": "default",
        }
        self.payload = {
            "source": "syscall",
            "rule": "Rule A",
            "priority": "Warning",
            "output_fields": {
                "k8s.pod.name": "vulnapp-new",
                "k8s.ns.name": "default",
            },
        }

    def client(self, api):
        app = create_app(k8s_api=api, environ=self.environ)
        app.config["TESTING"] = True
        return app.test_client()

    def test_rejects_unauthenticated_request(self):
        api = FakeCoreV1Api(pod("vulnapp-new", {"app": "vulnapp"}))
        response = self.client(api).post("/", json=self.payload)
        self.assertEqual(response.status_code, 401)
        self.assertEqual(api.calls, [])

    def test_ignores_unapproved_rule(self):
        api = FakeCoreV1Api(pod("vulnapp-new", {"app": "vulnapp"}))
        payload = dict(self.payload, rule="Unrelated informational rule")
        response = self.client(api).post(
            "/", json=payload, headers={"X-Falco-Token": "test-secret"}
        )
        self.assertEqual(response.status_code, 202)
        self.assertEqual(api.calls, [])

    def test_quarantines_before_retention_cleanup_and_preserves_metadata(self):
        target = pod(
            "vulnapp-new",
            {"app": "vulnapp", "pod-template-hash": "abc", "team": "security"},
        )
        old = pod("vulnapp-old", {"tainted-by-falco": "true", MANAGER_LABEL: MANAGER})
        api = FakeCoreV1Api(target, quarantined=[old])
        response = self.client(api).post(
            "/", json=self.payload, headers={"X-Falco-Token": "test-secret"}
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(target.metadata.labels["tainted-by-falco"], "true")
        self.assertEqual(target.metadata.labels["team"], "security")
        self.assertNotIn("app", target.metadata.labels)
        operations = [call[0] for call in api.calls]
        self.assertLess(operations.index("patch"), operations.index("delete"))

    def test_does_not_delete_evidence_when_patch_fails(self):
        target = pod("vulnapp-new", {"app": "vulnapp"})
        old = pod("vulnapp-old", {"tainted-by-falco": "true"})
        api = FakeCoreV1Api(target, quarantined=[old], patch_error=ApiException(status=409))
        response = self.client(api).post(
            "/", json=self.payload, headers={"X-Falco-Token": "test-secret"}
        )

        self.assertEqual(response.status_code, 502)
        self.assertNotIn("delete", [call[0] for call in api.calls])

    def test_rejects_pod_outside_managed_workload(self):
        api = FakeCoreV1Api(pod("database", {"app": "database"}))
        response = self.client(api).post(
            "/", json=self.payload, headers={"X-Falco-Token": "test-secret"}
        )
        self.assertEqual(response.status_code, 403)
        self.assertNotIn("patch", [call[0] for call in api.calls])

    def test_duplicate_alert_for_quarantined_pod_is_idempotent(self):
        api = FakeCoreV1Api(pod("vulnapp-new", {"tainted-by-falco": "true", MANAGER_LABEL: MANAGER}))
        response = self.client(api).post(
            "/", json=self.payload, headers={"X-Falco-Token": "test-secret"}
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json()["status"], "already-quarantined")
        self.assertNotIn("patch", [call[0] for call in api.calls])

    def test_official_reverse_shell_rule(self):
        self.environ.pop("ALLOWED_RULES")
        self.payload["rule"] = "Redirect STDOUT/STDIN to Network Connection in Container"
        api = FakeCoreV1Api(pod("vulnapp-new", {"app": "vulnapp"}))
        self.assertEqual(self.client(api).post("/", json=self.payload,
            headers={"X-Falco-Token": "test-secret"}).status_code, 200)

    def test_unrelated_and_unexported_evidence_never_deleted(self):
        unrelated = pod("other", {"tainted-by-falco": "true"})
        evidence = pod("evidence", {"tainted-by-falco": "true", MANAGER_LABEL: MANAGER})
        evidence.metadata.annotations.pop(EVIDENCE_EXPORTED)
        api = FakeCoreV1Api(pod("vulnapp-new", {"app": "vulnapp"}), [unrelated, evidence])
        self.client(api).post("/", json=self.payload, headers={"X-Falco-Token": "test-secret"})
        self.assertFalse(any(c[0] == "delete" for c in api.calls))

    def test_retry_resumes_cleanup_after_list_failure(self):
        class FailOnce(FakeCoreV1Api):
            failed = False
            def list_namespaced_pod(inner, **kwargs):
                if not inner.failed:
                    inner.failed = True
                    raise ApiException(status=503)
                return super().list_namespaced_pod(**kwargs)
        old = pod("old", {"tainted-by-falco": "true", MANAGER_LABEL: MANAGER})
        api = FailOnce(pod("vulnapp-new", {"app": "vulnapp"}), [old])
        c = self.client(api)
        self.assertEqual(c.post("/", json=self.payload, headers={"X-Falco-Token": "test-secret"}).status_code, 502)
        self.assertEqual(c.post("/", json=self.payload, headers={"X-Falco-Token": "test-secret"}).status_code, 200)
        self.assertIn(("delete", "old"), api.calls)
        self.assertEqual(sum(x[0] == "patch" for x in api.calls), 1)

    def test_order_uses_quarantine_not_creation_time(self):
        self.environ["MAX_QUARANTINED_PODS"] = "2"
        recent = pod("recent-incident", {"tainted-by-falco": "true", MANAGER_LABEL: MANAGER}, "2020-01-01T00:00:00Z")
        recent.metadata.annotations[QUARANTINED_AT] = "2026-09-19T00:00:00Z"
        old = pod("old-incident", {"tainted-by-falco": "true", MANAGER_LABEL: MANAGER}, "2026-09-01T00:00:00Z")
        api = FakeCoreV1Api(pod("vulnapp-new", {"app": "vulnapp"}), [recent, old])
        self.client(api).post("/", json=self.payload, headers={"X-Falco-Token": "test-secret"})
        self.assertIn(("delete", "old-incident"), api.calls)
        self.assertNotIn(("delete", "recent-incident"), api.calls)

    def test_unicode_token_is_rejected_without_server_error(self):
        api = FakeCoreV1Api(pod("vulnapp-new", {"app": "vulnapp"}))
        self.assertEqual(self.client(api).post("/", json=self.payload,
            headers={"X-Falco-Token": "è"}).status_code, 401)

    def test_namespace_and_json_validation(self):
        api = FakeCoreV1Api(pod("vulnapp-new", {"app": "vulnapp"}))
        c = self.client(api)
        h = {"X-Falco-Token": "test-secret"}
        self.assertEqual(c.post("/", json=[], headers=h).status_code, 400)
        self.payload["output_fields"]["k8s.ns.name"] = "kube-system"
        self.assertEqual(c.post("/", json=self.payload, headers=h).status_code, 403)
        self.assertEqual(api.calls, [])

    def test_probe_and_request_size(self):
        api = FakeCoreV1Api(pod("vulnapp-new", {"app": "vulnapp"}))
        c = self.client(api)
        self.assertEqual(c.get("/health").status_code, 200)
        self.assertEqual(c.get("/ready").status_code, 200)
        self.assertEqual(c.post("/", data="x" * 65537, content_type="application/json",
            headers={"X-Falco-Token": "test-secret"}).status_code, 413)

    def test_configuration_fails_closed(self):
        api = FakeCoreV1Api(pod("vulnapp-new", {"app": "vulnapp"}))
        for token in ("", "CHANGE_ME"):
            with self.assertRaises(RuntimeError):
                create_app(api, dict(self.environ, WEBHOOK_TOKEN=token))
        for timeout in ("0", "-1", "nan", "100"):
            with self.assertRaises(ValueError):
                create_app(api, dict(self.environ, K8S_REQUEST_TIMEOUT_SECONDS=timeout))

    def test_delete_failure_is_retryable_and_has_preconditions(self):
        class FailedDelete(FakeCoreV1Api):
            def delete_namespaced_pod(inner, name, namespace, body, **kwargs):
                self.assertEqual(body.preconditions.uid, "uid-old")
                self.assertEqual(body.preconditions.resource_version, "7")
                raise ApiException(status=409)
        old = pod("old", {"tainted-by-falco": "true", MANAGER_LABEL: MANAGER})
        api = FailedDelete(pod("vulnapp-new", {"app": "vulnapp"}), [old])
        r = self.client(api).post("/", json=self.payload, headers={"X-Falco-Token": "test-secret"})
        self.assertEqual(r.status_code, 503)
        self.assertEqual(r.json["cleanup"], "retry-required")

    def test_concurrent_response_is_retryable_and_health_remains_available(self):
        import threading
        entered, release = threading.Event(), threading.Event()
        class SlowRead(FakeCoreV1Api):
            def read_namespaced_pod(inner, *args, **kwargs):
                entered.set()
                release.wait(3)
                return super().read_namespaced_pod(*args, **kwargs)
        api = SlowRead(pod("vulnapp-new", {"app": "vulnapp"}))
        app = create_app(api, self.environ)
        def send():
            with app.test_client() as c:
                c.post("/", json=self.payload, headers={"X-Falco-Token": "test-secret"})
        worker = threading.Thread(target=send)
        worker.start()
        try:
            self.assertTrue(entered.wait(2))
            with app.test_client() as c:
                self.assertEqual(c.get("/health").status_code, 200)
                self.assertEqual(c.post("/", json=self.payload,
                    headers={"X-Falco-Token": "test-secret"}).status_code, 503)
        finally:
            release.set()
            worker.join(4)


if __name__ == "__main__":
    unittest.main()
