# SonarQube on Kubernetes

## Prerequisites
```bash
#Make sure namespace exits
kubectl apply -f namespace.yaml
```

## Apply database
```bash
kubectl apply -f postgresql
```

## Installation

```bash
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
helm upgrade --install sonarqube sonarqube/sonarqube \
  -n sonarqube \
  -f values.yaml
