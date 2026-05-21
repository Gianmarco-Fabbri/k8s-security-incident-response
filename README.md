# Kubernetes Security & Incident Response Laboratory

This repository contains the source files and laboratory materials for a comprehensive, hands-on academic module focused on **Kubernetes Runtime Security, Automated Incident Response, and Proactive Prevention**. 

The entire laboratory procedure, including theoretical background and detailed step-by-step exercises, is documented in the accompanying handbook: **[Download the Laboratory Guide (PDF)](./SpecialProject07_Runtime_Security.pdf)**.

---

## Laboratory Overview & Architecture

The laboratory guides students through the design and implementation of a modern runtime security architecture for containerized workloads. It simulates a realistic security incident lifecycle, spanning from initial workload compromise to real-time detection, automated response, and proactive system-call hardening.

### Key Educational Objectives

1. **Runtime Threat Detection**: Simulating real-world container attack vectors—such as command injection, service account token exfiltration, and anti-debugging techniques—and capturing anomalous behavior using **Falco** (via eBPF instrumented at the kernel level).
2. **Automated Incident Response**: Implementing a reactive event-driven workflow using **Falcosidekick** and a custom **Python security engine** to dynamically isolate compromised pods at the Kubernetes API level.
3. **Proactive Defense-in-Depth**: Leveraging **Seccomp** (Secure Computing Mode) profiles to restrict dangerous system calls (such as `connect` and `ptrace`), demonstrating how to prevent exploits prior to runtime execution.

---

## Repository Structure

*   [`SpecialProject07_Runtime_Security.pdf`](./SpecialProject07_Runtime_Security.pdf): The complete, publication-grade laboratory handbook (in Italian).
*   [`material/`](./material/): Technical resources and Kubernetes manifests:
    *   [`falco_handler/`](./material/falco_handler/): Python incident response script and the corresponding Kubernetes RBAC and Deployment manifests.
    *   [`payloads/`](./material/payloads/): Scripts and payloads utilized to simulate targeted attacks.
    *   [`seccomp_profiles/`](./material/seccomp_profiles/): Custom Seccomp JSON configurations to restrict container capabilities.
*   [`report/`](./report/): LaTeX source files and assets utilized to compile the laboratory handbook.

---

## Environment & Prerequisites

The laboratory environment is optimized for standard Kubernetes distributions and has been extensively validated on **CrownLabs VMs** and Ubuntu nodes provisioned with `kubeadm`:
*   **Kubernetes Cluster** (version 1.28 or later) with a supported CNI plugin (e.g., Cilium or Calico).
*   **Helm v3** package manager.
*   **Seccomp Default Profile** support enabled in the container runtime (`containerd`).

---

## License

This project is licensed under the terms of the MIT License. Detailed terms can be found in the [LICENSE](./LICENSE) file.
