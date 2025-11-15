# Install Cilium (via Helm) — Run on Control Plane

```bash
    # Add Helm repo
    helm repo add cilium https://helm.cilium.io/
    helm repo update

    helm upgrade -i cilium cilium/cilium \
     --namespace kube-system \
     --set egress-masquerade-interfaces=enp0s6 \
     -f values.yaml \
     --version 1.16.3
```
     --set direct-routing-device=tailscale0 \
