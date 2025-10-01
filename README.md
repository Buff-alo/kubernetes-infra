# Kubernetes-infra
# 🌐 Multicloud K3s Cluster — AWS Control Plane + GCP Worker (Tailscale Network)

This document outlines the steps and prerequisites for setting up a **multicloud Kubernetes (K3s)** cluster with:

* 🟡 **AWS** (Control Plane)
* 🔵 **GCP** (Worker Node)
* 🧠 **K3s** for lightweight Kubernetes
* 🌍 **Tailscale** for secure cross-cloud networking

> ⚠️ This setup is meant for **personal labs** and **free-tier resources**. It is **not production-grade**.

---

## 📝 Prerequisites

* ✅ AWS account (Free Tier enabled)
* ✅ GCP account (Free Tier enabled)
* ✅ Basic Linux command-line experience
* ✅ Tailscale account (Free or Personal Plan)
* 🧠 SSH access to both instances
* ⚡ Stable Internet connection

---

## 🧱 Infrastructure Overview

| Role           | Provider | Instance Type | OS     | Network       |
| -------------- | -------- | ------------- | ------ | ------------- |
| Control Plane  | AWS      | t3.micro      | Ubuntu | Tailscale VPN |
| Worker Node #1 | GCP      | e2-micro      | Ubuntu | Tailscale VPN |

* K3s is installed on both nodes.
* Tailscale provides the secure private network between clouds.
* Worker nodes join the control plane using the **Tailscale IP**.

---

## ⚙️ 1. Provision the Instances

### AWS — Control Plane

* Launch a **t3.micro** Ubuntu instance.
* Allow inbound SSH (port 22) from your IP.
* Update system:

  ```bash
  sudo apt update && sudo apt upgrade -y
  ```

### GCP — Worker Node

* Launch an **e2-micro** Ubuntu instance.
* Allow inbound SSH.
* Update system:

  ```bash
  sudo apt update && sudo apt upgrade -y
  ```

---

## 🔐 2. Install and Configure Tailscale

Install Tailscale on **both nodes**:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --authkey=<YOUR_TAILSCALE_AUTH_KEY> --hostname=<HOSTNAME>
```

* Example:

  * Control plane → `kls-controlplane-01`
  * Worker node → `kls-worker-01`

Verify connectivity:

```bash
tailscale ip -4
ping <tailscale-ip-of-other-node>
```

---

## 🧠 3. Install K3s (Control Plane)

Run the following on the **AWS control plane**:

```bash
curl -sfL https://get.k3s.io | sh -
```

Check status:

```bash
sudo k3s kubectl get nodes
```

Retrieve the join token:

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

Get the **Tailscale IP** of the control plane (e.g., `100.x.x.x`):

```bash
tailscale ip -4
```

---

## 🧠 4. Install K3s (Worker Node)

### Control Plane (AWS)

1. Create `/etc/rancher/k3s/config.yaml` file for K3s server configuration.
2. Include relevant configurations such as:

   ```yaml
   # /etc/rancher/k3s/config.yaml
    write-kubeconfig-mode: "0644"
    node-name: kls-controlplane-01
    node-ip: 100.x.y.z           # Tailscale IP of control plane
    advertise-address: 100.x.y.z # Tailscale IP for other nodes to connect
    bind-address: 0.0.0.0
    cluster-cidr: 10.42.0.0/16
    service-cidr: 10.43.0.0/16
    disable-cloud-controller: true
    flannel-iface: tailscale0           # Flannel to tailscale interface                     # if you're running Traefik separately as a Docker container
    tls-san:
    - 100.x.y.z                # Tailscale IP
    - kls-controlplane-01
   ```
3. Install K3s using:

   ```bash
   curl -sfL https://get.k3s.io | sh -
   ```
4. Verify K3s server is running:

   ```bash
   sudo systemctl status k3s
   kubectl get nodes
   ```

### Worker Node (GCP)

1. Create `/etc/rancher/k3s/config.yaml` file for K3s agent configuration.
2. Include server URL and token:

   ```yaml
   # Example config
   # /etc/rancher/k3s/config.yaml
    server: https://100.x.y.z:6443   # Tailscale IP of control plane
    token: YOUR_CLUSTER_TOKEN           # from /var/lib/rancher/k3s/server/node-token on control plane
    node-name: kls-worker-01.us-west1-c.c.kwadwolabs.internal
    node-ip: 100.x.y.z              # Tailscale IP of this worker
    flannel-iface: tailscale0           # Flannel to tailscale interface
    ```
3. Install K3s agent using:

   ```bash
   curl -sfL https://get.k3s.io | K3S_URL=https://<control-plane-tailscale-ip>:6443 K3S_TOKEN=<node-token> sh -
   ```
4. Verify node has joined the cluster:

   ```bash
   kubectl get nodes


## 📦 5. Deploy a Test Application

On the **control plane**, deploy Nginx:

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pods -o wide
```

Find the **worker node** Tailscale IP and the **NodePort** assigned (e.g., `30080`):

```bash
kubectl get svc
```

Access it from your local machine via:

```
http://<worker-tailscale-ip>:<nodeport>
```

---

## 🗃 6. Persistence Pattern (To Implement Later)

Two main approaches for persistent storage in a multicloud lab:

1. **External Managed DB (Recommended)**

   * Use AWS RDS, GCP Cloud SQL, or similar free-tier managed database.
   * Configure your apps to connect to it via private/public endpoint.

2. **PV-backed In-Cluster Database** *(Advanced)*

   * Deploy PostgreSQL/MySQL inside the cluster.
   * Use cloud-specific storage backends for PVs:

     * AWS → EBS
     * GCP → Persistent Disk
   * Or use a portable storage solution like **NFS**, **Longhorn**, or **Rook/Ceph** across nodes.

> For now, this setup only documents the pattern; storage classes and PV provisioning are not implemented yet.

---

## 🧹 Cleanup

To tear down:

```bash
# On worker
sudo k3s-killall.sh
sudo k3s-uninstall.sh

# On control plane
sudo k3s-killall.sh
sudo k3s-uninstall.sh
```

Delete your instances from AWS & GCP to avoid charges.

---

## 🧠 Notes & Tips

* Both nodes are **tiny** (1 vCPU / ~1 GB RAM), so keep workloads minimal.
* Tailscale allows cross-cloud communication without exposing control plane to the public Internet.
* If control plane goes offline, the cluster becomes **unmanageable**, even if worker pods keep running.
* Adding more worker nodes is as simple as repeating the **join command** on additional instances.
* This setup uses a stretched cluster across different cloud providers.
* K3s configuration is centralized in `/etc/rancher/k3s/config.yaml`.
* Tailscale provides secure networking between nodes.
* This documentation serves as a reference pattern for multicloud Kubernetes deployment.

---

## 🧭 Next Steps

* ✅ Add more worker nodes (e.g., Azure, local laptop, Oracle free tier)
* ✅ Set up a **LoadBalancer** alternative (e.g., MetalLB) for multi-node service access
* ✅ Configure **Persistent Volumes**
* ✅ Add **Ingress Controller** (Traefik / NGINX) for better routing
* ✅ Automate provisioning with Terraform & Ansible

---

**Author:** Kwadwo Ofosu Boakye
**Use Case:** Personal Multicloud Kubernetes Lab 🧪

