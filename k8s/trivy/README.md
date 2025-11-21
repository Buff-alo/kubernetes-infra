# Trivy Operator on Kubernetes

## Installation

```bash
  helm install trivy-operator oci://ghcr.io/aquasecurity/helm-charts/trivy-operator \
  --namespace trivy-system \
  --create-namespace \
  -f trivy-values.yaml
```
