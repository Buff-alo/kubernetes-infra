# SonarQube on Kubernetes

## Installation

```bash
kubectl apply -f namespace.yaml
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
helm upgrade --install sonarqube sonarqube/sonarqube \
  -n sonarqube \
  -f values.yaml
