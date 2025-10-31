# Trivy Operator on Kubernetes

## Installation

```bash
helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update
helm install trivy-operator oci://ghcr.io/aquasecurity/helm-charts/trivy-operator \
     --namespace trivy-system \
     --create-namespace \
     --version 0.31.0 \
     --values ./values.yaml 

Inspect created VulnerabilityReports by:

    kubectl get vulnerabilityreports --all-namespaces -o wide

Inspect created ConfigAuditReports by:

    kubectl get configauditreports --all-namespaces -o wide

Inspect the work log of trivy-operator by:

    kubectl logs -n trivy-system deployment/trivy-operator