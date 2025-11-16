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
  --values loki-values.yaml
```

accessKeyId: loki
secretAccessKey: loki@minio