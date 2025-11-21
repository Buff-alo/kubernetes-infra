# Trivy Operator on Kubernetes

## Installation

```bash
  helm install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --create-namespace \
  -f values-stretched.yaml
```
