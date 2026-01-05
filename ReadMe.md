# Kubernetes-infra

# 🌐 Multicloud K3s Platform — OCI Control Plane + GCP Worker + AWS Worker (Tailscale Mesh)

This repository documents a **multi-cloud K3s platform** built with free-tier resources, automated with Terraform & Ansible, and extended with persistent storage, object storage, DevSecOps tooling, and observability. The goal: reproducible lab that mimics production constraints across providers while staying cost-conscious.

**Author:** Kwadwo Ofosu Boakye  
**Status:** Lab / PoC — not recommended for production without hardening and SLA-grade infrastructure.

---

## 🚀 What this repo contains (summary)

- Multicloud control plane & workers: **OCI (control plane)**, **AWS (worker)**, **GCP (worker)**  
- Secure overlay networking: **Tailscale** (inter-node connectivity across clouds)  
- Automated provisioning: **Terraform** (cloud resources) + **Ansible** (bootstrap & cluster config)  
- Kubernetes: **K3s** lightweight distribution  
- Persistent & object storage: **Longhorn** (block storage), **MinIO** (S3-compatible)  
- DevSecOps: **Trivy Operator** (image/policy scanning), **SonarQube** (code quality)  
- Observability / Logging (PLG): **Promtail**, **Loki**, **Grafana**  
- Examples & manifests: Helm values, example K3s config, bootstrap playbooks

---

## 🔎 Project goals

1. Build a truly multicloud, cross-provider K3s cluster using only free or low-cost resources.  
2. Automate infra + bootstrap using Terraform + Ansible so cluster bring-up is repeatable.  
3. Provide persistent and object storage inside the cluster (Longhorn + MinIO).  
4. Integrate DevSecOps (Trivy + SonarQube) and observability (PLG stack).  
5. Document the pattern and provide a blueprint that can scale into more resilient setups.

---

## Architecture overview

```mermaid
                        ┌─────────────────────────┐
                        │      Tailscale Mesh     │
                        └─────────────────────────┘
                           /        |         \
          ┌────────────┐  /         |          \  ┌────────────┐
          │   OCI      │─/──────────┼───────────\─│   AWS      │
          │ Control    │            |             │ Worker     │
          │ Plane      │            |             └────────────┘
          └────────────┘            |
                 \                  |
                  \                 |
                   \                |
                    ┌───────────────▼──────────────┐
                    │       K3s Cluster (multicloud)│
                    │  Longhorn  MinIO  Trivy  Loki │
                    └───────────────────────────────┘
```


Core network: Tailscale overlay connects all nodes; K3s cluster CIDR spans nodes so pods can talk cluster-wide.

---

## Prerequisites

- Accounts: AWS, GCP, OCI (free-tier recommended)  
- Local: `terraform`, `ansible`, `kubectl`, `helm`, `git`  
- Tailscale account / auth key (to programmatically join nodes)  
- SSH key accessible to Terraform/Ansible (or cloud VM access)  
- Basic Linux & Kubernetes CLI knowledge

---

## Quickstart — high level

> This doc provides the blueprint & reference. See `terraform/` and `playbooks/` directories for runnable code (inventory & variable files required).

1. Provision VMs (Terraform): OCI control plane, GCP worker, AWS worker.  
2. Install and configure Tailscale on each VM (Terraform/Ansible will distribute auth key).  
3. Install K3s on control plane (K3s config uses control-plane Tailscale IP as `node-external-ip`).  
4. Install K3s agent on each worker with the control-plane Tailscale IP + node token.  
5. Deploy storage, object store, monitoring, and security tooling via Helm.

---

## K3s Server configuration (reference `/etc/rancher/k3s/config.yaml`)

Use the control plane Tailscale IP for `node-external-ip` and `tls-san`. Example:

```yaml
# /etc/rancher/k3s/config.yaml
   write-kubeconfig-mode: "0644"
   node-name: kls-controlplane-01
   node-external-ip: 100.x.y.z # Tailscale IP of control plane
   vpn-auth: "name=tailscale,joinKey=< tailscale_auth_key>"
   bind-address: 0.0.0.0
   cluster-cidr: 10.42.0.0/16
   service-cidr: 10.43.0.0/16                  
   tls-san:
     - 100.x.y.z # Tailscale IP
     - kls-controlplane-01
   disable: #if You want these disabled 
      - traefik
      - servicelb
      - local-storage
```
Ansible role templates if using  K3s ansible role
```jinja
    write-kubeconfig-mode: "0644"
    node-name: {{ server_hostname }}
    node-external-ip: {{ server_ip }}
    # advertise-address: {{ server_ip }}
    vpn-auth: "name=tailscale,joinKey={{ tailscale_auth_key }}"
    bind-address: 0.0.0.0
    cluster-cidr: 10.42.0.0/16
    service-cidr: 10.43.0.0/16
    # flannel-iface: tailscale0
    # flannel-backend: none
    tls-san:
        - {{ server_ip }}
        - {{ server_hostname }}
    disable:
    - traefik
    - servicelb
    - local-storage
```

## K3s Worker configuration (reference `/etc/rancher/k3s/config.yaml`)
```yaml
   # Example config
   # /etc/rancher/k3s/config.yaml
   server: https://100.x.y.z:6443 # Tailscale IP of control plane
   token: YOUR_CLUSTER_TOKEN # from /var/lib/rancher/k3s/server/node-token on control plane
   node-name: YOUR_WORKER_NODE_NAME
   node-external-ip: 100.x.y.z # Tailscale IP of this worker
   vpn-auth: "name=tailscale,joinKey=< tailscale_auth_key>"
```
Ansible role templates
```jinja
server: https://{{ server_ip }}:6443
token: {{ k3s_node_token }}
node-name: {{ worker_hostname }}
node-external-ip: {{ worker_ip }}
vpn-auth: "name=tailscale,joinKey={{ tailscale_auth_key }}"
```