# Trivy Operator on Kubernetes

## Installation

```bash
kubectl apply -f k8s/trivy/IAM/
kubectl apply -f k8s/trivy/crds/
kubectl apply -f k8s/trivy/configmap.yaml
kubectl apply -f k8s/trivy/deployment.yaml
