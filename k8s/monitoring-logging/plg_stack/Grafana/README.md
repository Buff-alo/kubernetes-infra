## Create Grafana Cred
```bash
kubectl create secret generic grafana-admin-credentials \
  --namespace logging \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='YourSecurePassword'
```

## Install Grafana 
```bash
helm upgrade --install grafana grafana/grafana \
  -n logging \
  -f grafana-values.yaml
```