```bash
# 1. Add the repo (if you haven't already)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
```bash
# 2. Deploy into the SAME namespace as Grafana/Loki (recommended for DNS simplicity)
helm install prometheus prometheus-community/prometheus \
  -n logging \
  -f prometheus-values.yaml
```