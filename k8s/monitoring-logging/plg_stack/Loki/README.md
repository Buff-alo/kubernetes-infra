## Create essential secrets

```bash
kubectl create secret generic loki-s3-secrets \
  --namespace logging \
  --type=Opaque \
  --from-literal=AWS_ACCESS_KEY_ID=minioadmin \
  --from-literal=AWS_SECRET_ACCESS_KEY=minioadmin
```

## Install Loki aggregator

```bash
helm upgrade --install loki grafana/loki \
  -n logging \
  -f loki-values.yaml 
```

## Cleanup

```bash
helm uninstall loki -n logging
```
## Restart
```bash
helm uninstall loki -n logging
helm upgrade --install loki grafana/loki -n logging -f loki-values.yaml
```
helm uninstall loki -n logging

kubectl delete pvc --all -n logging --force --grace-period=0

helm upgrade --install loki grafana/loki \
  -n logging \
  -f loki-values.yaml 