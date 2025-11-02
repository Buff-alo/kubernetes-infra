# Trivy Operator on Kubernetes

## Installation

```bash
    kubectl apply -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/v0.29.0/deploy/static/trivy-operator.yaml

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
