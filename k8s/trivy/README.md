# Trivy Operator on Kubernetes

## Installation

```bash
  helm upgrade --install trivy-operator oci://ghcr.io/aquasecurity/helm-charts/trivy-operator \
  --namespace trivy-system \
  --create-namespace \
  -f trivy-values.yaml
```

## Configuration for smooth deployment
```bash
kubectl -n trivy-system patch deploy trivy-operator --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/hostNetwork",
    "value": true
  },
  {
    "op": "add",
    "path": "/spec/template/spec/dnsPolicy",
    "value": "ClusterFirstWithHostNet"
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/env/-",
    "value": {"name": "GODEBUG", "value": "netdns=go"}
  }
]'
```