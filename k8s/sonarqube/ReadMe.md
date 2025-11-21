# SonarQube on Kubernetes

## Prerequisites
```bash
#Make sure namespace exits
kubectl apply -f namespace.yaml
kubectl create ns sonarqube

#Create secrets
kubectl create secret generic loki-s3-secrets \
  --namespace logging \
  --type=Opaque \
  --from-literal=AWS_ACCESS_KEY_ID=minioadmin \
  --from-literal=AWS_SECRET_ACCESS_KEY=minioadmin
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
```

## CleanUP
```bash

```