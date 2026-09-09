# Automated Kubernetes Runtime Security & Threat Containment

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28%2B-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Falco](https://img.shields.io/badge/Falco-v0.40%2B-00AEC7?logo=falco&logoColor=white)](https://falco.org/)
[![Cilium](https://img.shields.io/badge/Cilium-eBPF%20v1.15.14-F05A24?logo=cilium&logoColor=white)](https://cilium.io/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Academic Project](https://img.shields.io/badge/Evaluation-31%2F30%20Cum%20Laude-brightgreen.svg)]()

An enterprise-grade, closed-loop runtime threat detection, forensic isolation, and automated self-healing architecture for Kubernetes workloads, powered by **Falco**, **Falcosidekick**, and **Cilium eBPF**.

---

## 📖 Complete Laboratory Handbook

For a comprehensive, publication-grade academic analysis (theoretical foundations, kernel mechanics, and step-by-step reproduction instructions), refer to the accompanying handbook:  
📄 **[Download the Laboratory Guide (PDF)](./Kubernetes_Runtime_Security_Guide.pdf)**

---

## 🎯 The Problem & Vision

In containerized environments, Linux kernel namespaces and cgroups provide workload segregation but do **not** prevent exploitation when application code is vulnerable. Once an attacker obtains code execution (e.g., via Command Injection), they can:
1. Establish interactive reverse shells (C2 channels).
2. Steal Kubernetes ServiceAccount JWT tokens to pivot across the cluster.
3. Deploy evasive payloads using anti-debugging syscalls (`ptrace`).

Traditional perimeter defenses fail to detect in-container malicious actions, while naive response mechanisms (such as `kubectl delete pod`) cause **service disruption (Denial of Service)** and **destroy volatile memory artifacts** critical for digital forensics.

### The Solution: A Closed-Loop Self-Healing Pipeline
This project establishes a **zero-touch incident response pipeline**:
* **Real-Time Detection:** Falco intercepts malicious system calls (`dup2`, `ptrace`, `execve`) directly at the kernel boundary via eBPF/kmod.
* **Forensic Quarantine:** An event-driven microservice (**Falco Handler**) dynamically strips application labels using a **Kubernetes Strategic Merge Patch**, detaching the compromised pod from its ReplicaSet without terminating it.
* **Zero Downtime (Auto-Healing):** The ReplicaSet detects the missing replica and immediately provisions a fresh, healthy pod, ensuring 100% service availability for legitimate users.
* **Kernel eBPF Network Isolation:** A **CiliumNetworkPolicy** matches the tainted workload label and applies a strict bidirectional **Default Deny** at the eBPF datapath level ($O(1)$ hash map lookup), instantly killing attacker sockets and halting lateral movement.

---

## 🏗️ Architecture & Workflow

```
+----------------------------------------------------------------------------------------------------+
|                                  KUBERNETES RUNTIME SECURITY PIPELINE                              |
+----------------------------------------------------------------------------------------------------+

     [ Attacker ]
          |
          | 1. Exploits Command Injection (Reverse Shell / ptrace)
          v
   +--------------+       Intercepts Syscall (dup2 / ptrace)      +--------------------+
   |   vulnapp    | --------------------------------------------> |    Linux Kernel    |
   |  Container   |                                               | (Falco eBPF/kmod)  |
   +--------------+                                               +--------------------+
          |                                                                  |
          |                                                                  | 2. Real-Time Security Alert
          |                                                                  v
          |                                                       +--------------------+
          |                                                       |    Falco Daemon    |
          |                                                       +--------------------+
          |                                                                  |
          |                                                                  | 3. Internal gRPC Channel
          |                                                                  v
          |                                                       +--------------------+
          |                                                       |   Falcosidekick    |
          |                                                       +--------------------+
          |                                                                  |
          |             4. HTTP POST Webhook (/health, /)                    v
          |      +---------------------------------------------------------------------+
          |      |
          v      v
   +--------------------+     5. Strategic Merge Patch        +--------------------+
   |   Falco Handler    | ----------------------------------> |   K8s API Server   |
   | (Gunicorn / Flask) |     - Nullifies 'app=vulnapp'       +--------------------+
   +--------------------+     - Sets 'tainted-by-falco=true'             |
                                                                         | 6. Cluster Event Fan-out
          +--------------------------------------------------------------+
          |                                                              |
          v                                                              v
+-------------------+                                          +--------------------+
|    ReplicaSet     |                                          |    Cilium CNI      |
|   Auto-Healing    |                                          |   eBPF Datapath    |
+-------------------+                                          +--------------------+
          |                                                              |
          | Auto-provisions fresh, clean replica                         | Drops Ingress & Egress
          v                                                              v
  [ vulnapp-healthy ] (Zero Downtime!)                         [ 100% Packet Loss ]
                                                               (Reverse shell severed!)
```

---

## ⚡ Key Engineering & Security Highlights

### 1. Atomic Workload Decoupling (Strategic Merge Patch)
Instead of invoking `kubectl` via subprocess, the handler leverages the official `kubernetes.client.CoreV1Api`. It queries the compromised pod's labels and constructs a Strategic Merge Patch where all existing keys are set to `None` (`null` in JSON) and `tainted-by-falco: "true"` is injected:
```python
patch_labels = {k: None for k in existing_labels.keys()}
patch_labels["tainted-by-falco"] = "true"
k8s_core_v1.patch_namespaced_pod(name=pod, namespace=namespace, body={"metadata": {"labels": patch_labels}})
```
* **Effect:** The pod is immediately detached from the `Service` and `ReplicaSet`.
* **Zero Downtime:** The ReplicaSet notices `replicas: 0/1` and immediately spins up a clean replica.
* **Forensic Readiness:** The infected container remains running in memory for volatility extraction and memory dump analysis.

### 2. Anti-DoS & Zombie Pod Protection
If an attacker repeatedly triggers alerts to exhaust cluster resources with quarantined pods, the handler enforces a namespace-scoped limit: before quarantining the target, it queries and forcibly deletes (`grace_period_seconds=0`) any previously tainted pods:
```python
quarantined_pods = k8s_core_v1.list_namespaced_pod(namespace=namespace, label_selector="tainted-by-falco=true")
for q_pod in quarantined_pods.items:
    if q_pod.metadata.name != pod:
        k8s_core_v1.delete_namespaced_pod(name=q_pod.metadata.name, namespace=namespace, ...)
```
This guarantees that **at most 1 quarantined pod** exists per namespace, preventing resource starvation attacks.

### 3. Concurrency Control & Anti-TOCTOU Architecture
To prevent **Time-of-Check to Time-of-Use (TOCTOU)** race conditions during high-volume alert storms:
* The handler container runs **Gunicorn with a single worker thread** (`--workers 1`).
* The deployment is strictly locked to `replicas: 1` (no HPA).
* Requests are serialized deterministically, eliminating API conflicts and race conditions without requiring complex distributed locking primitives (e.g., Kubernetes Leases).

### 4. Zero-Touch Network Containment via Cilium eBPF
The `CiliumNetworkPolicy` matches the quarantine label and defines empty ingress/egress rules, activating absolute Default Deny at the kernel layer:
```yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: isolate-tainted-pods
spec:
  endpointSelector:
    matchLabels:
      tainted-by-falco: "true"
  ingress: []
  egress: []
```
Outbound traffic (such as ICMP pings or TCP reverse shell traffic) encounters **100% packet loss** instantly via eBPF BPF map lookups ($O(1)$ efficiency).

### 5. False-Positive Tuning & API Alert Loop Prevention
* **CRI Latency Workaround:** In modern container runtimes (Containerd), asynchronous metadata enrichment can delay `proc.name` population. Custom rules utilize `proc.cmdline contains '...'` to synchronously inspect process memory at the syscall event boundary.
* **Loop Prevention:** Calling the Kubernetes API server from inside a pod triggers Falco's default rule `Contact K8S API Server From Container`. To prevent an infinite recursion of alerts between Falco and the handler, the `user_known_contact_k8s_api_server_activities` macro is explicitly overridden in Helm values to whitelist the handler image.

---

## 🔬 Attack Scenarios Demonstrated

| Attack Vector | MITRE ATT&CK | Syscall / Target | Detection Mechanism | Containment Action |
|---|---|---|---|---|
| **Reverse Shell** | **T1059** (Command & Scripting Interpreter) | `dup2` / `dup3` redirecting I/O to TCP socket | Falco default rule `Redirect STDOUT/STDIN to Network Connection` | Pod label stripped + Cilium Default Deny + Replica auto-healed |
| **ServiceAccount Token Theft** | **T1528** (Steal Application Access Token) | `/var/run/secrets/kubernetes.io/serviceaccount/token` | Falco `Sensitive file opened for reading` (`/etc/shadow`) | Read detected; mitigated via `automountServiceAccountToken: false` |
| **Debugger Evasion** | **T1622** (Debugger Evasion) | `ptrace(PTRACE_TRACEME)` | Falco default rule `PTRACE anti-debug attempt` | Pod quarantined; debugger evasion alerted |
| **Ingress Tool Transfer** | **T1105** (Ingress Tool Transfer) | `execve` of `wget`, `curl`, `ncat` | Custom Falco rule `Detect Network Tools in vulnapp` | Alert triggered via `proc.cmdline` kernel inspection |

---

## 📂 Repository Structure

```text
.
├── Kubernetes_Runtime_Security_Guide.pdf  # Comprehensive academic lab handbook
├── LICENSE                                # MIT License
├── README.md                              # Technical documentation
├── material/                              # Deployment manifests & source code
│   ├── falco_handler/                     # Incident response microservice
│   │   ├── falco-handler-deployment.yaml  # Deployment with health probes & limits
│   │   ├── falco-handler-rbac.yaml        # Scoped RBAC (get, list, patch, delete)
│   │   ├── falco-handler-service.yaml     # Internal ClusterIP service
│   │   └── src/
│   │       ├── Dockerfile                 # Hardened non-root image (Gunicorn)
│   │       └── handler.py                 # Core event-driven response engine
│   ├── manifests/                         # Target application & policy manifests
│   │   ├── isolate-tainted-policy.yaml    # CiliumNetworkPolicy (Default Deny)
│   │   ├── vulnapp-deployment.yaml        # Vulnerable target deployment
│   │   └── vulnapp-service.yaml           # NodePort service on port 32080
│   ├── payloads/                          # Exploit scripts & compiled binaries
│   │   └── ptrace.c                       # C payload invoking PTRACE_TRACEME
│   └── vulnapp/                           # Target application source
│       ├── Dockerfile                     # Python 3.10-slim container
│       ├── app.py                         # Flask app with deliberate command injection
│       ├── requirements.txt               # Dependencies (Flask)
│       └── templates/index.html           # Web diagnostic interface
└── report/                                # LaTeX source files of the lab report
    ├── images/
    ├── main.pdf
    ├── main.tex
    ├── other/
    └── src/
        ├── ch1.tex                        # Introduction & Background
        ├── ch2.tex                        # Cluster Setup & Cilium Installation
        ├── ch3.tex                        # Threat Scenarios & Detection
        └── ch4.tex                        # Automated Response & Incident Containment
```

---

## 🚀 Quickstart & Reproduction Guide

### Prerequisites
* A Kubernetes cluster (v1.28+) with standard Linux kernel (Ubuntu 20.04/22.04 recommended).
* `kubectl` and `helm` installed.
* Cilium CLI installed.

### 1. Install Cilium CNI (with eBPF Datapath)
```bash
cilium install --version 1.15.14
cilium status --wait
```

### 2. Deploy the Target Application (`vulnapp`)
```bash
# Build and load image into container runtime (e.g. Containerd)
cd material/vulnapp
docker build -t vulnapp:latest .
docker save vulnapp:latest | sudo ctr -n k8s.io images import -

# Deploy application
cd ../manifests
kubectl apply -f vulnapp-deployment.yaml
kubectl apply -f vulnapp-service.yaml
```

### 3. Deploy the Incident Response Handler
```bash
# Build handler image
cd ../falco_handler/src
docker build -t falco-handler:latest .
docker save falco-handler:latest | sudo ctr -n k8s.io images import -

# Deploy RBAC, Service, and Handler Deployment
cd ..
kubectl apply -f falco-handler-rbac.yaml
kubectl apply -f falco-handler-deployment.yaml
kubectl apply -f falco-handler-service.yaml
```

### 4. Install Falco with Falcosidekick & Whitelist Macro
Create `falco-values.yaml`:
```yaml
tty: true
driver:
  kind: kmod # Or modern-bpf if BTF is supported on your kernel

falcosidekick:
  enabled: true
  config:
    webhook:
      enabled: true
      address: "http://falco-handler.default.svc.cluster.local:5000/"

customRules:
  loop-whitelist.yaml: |-
    - macro: user_known_contact_k8s_api_server_activities
      condition: (container.image.repository = 'falco-handler')
```

Install via Helm:
```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm install falco falcosecurity/falco -n falco --create-namespace -f falco-values.yaml
```

### 5. Apply the Cilium Network Isolation Policy
```bash
kubectl apply -f material/manifests/isolate-tainted-policy.yaml
```

---

## 🧪 Validating Threat Containment

### Triggering the Exploit (via `ptrace`)
Compile and inject the anti-debugging payload into the running pod:
```bash
gcc -o material/payloads/ptrace material/payloads/ptrace.c
POD=$(kubectl get pod -l app=vulnapp -o jsonpath='{.items[0].metadata.name}')

kubectl cp material/payloads/ptrace $POD:/tmp/ptrace
kubectl exec $POD -- /tmp/ptrace
```

### Observing the Automated Response
1. **Falco Logs:**
   ```bash
   kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco --tail=5
   ```
   *Output:* `Notice Detected potential PTRACE_TRACEME anti-debug attempt`

2. **Workload Quarantine & Auto-Healing:**
   ```bash
   kubectl get pods --show-labels
   ```
   *Output:*
   ```text
   NAME                           READY   STATUS    AGE    LABELS
   vulnapp-5d5997f998-98ncq       1/1     Running   12m    tainted-by-falco=true
   vulnapp-5d5997f998-zcnq9       1/1     Running   20s    app=vulnapp,pod-template-hash=5d5997f998
   ```
   *Notice:* The infected pod is detached and labeled `tainted-by-falco=true`, while a new replica has been automatically provisioned to serve user traffic.

3. **Cilium Network Isolation:**
   ```bash
   kubectl exec $POD -- ping -c 3 8.8.8.8
   ```
   *Output:*
   ```text
   --- 8.8.8.8 ping statistics ---
   3 packets transmitted, 0 received, 100% packet loss, time 2048ms
   command terminated with exit code 1
   ```
   *Result:* All inbound and outbound traffic is blocked by Cilium eBPF!

---

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

## 👤 Author

**Gianmarco Fabbri**  
Master's Degree in Computer Engineering - Network and Cloud Security  
*Politecnico di Torino*
