## Create essential secrets

```bash
kubectl create secret generic loki-s3-secrets \
  --namespace logging \
  --type=Opaque \
  --from-literal=access-key=minioadmin \
  --from-literal=secret-key=minioadmin
```

## Install Loki aggregator

```bash
helm upgrade --install loki grafana/loki \
  -n logging \
  -f loki-values.yaml \
  --set minio.accessKey=$(kubectl get secret loki-s3-secrets -n logging -o jsonpath='{.data.accessKeyId}' | base64 -d) \
  --set minio.secretKey=$(kubectl get secret loki-s3-secrets -n logging -o jsonpath='{.data.secretAccessKey}' | base64 -d)
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

helm upgrade --install loki grafana/loki -n logging -f loki-values.yaml