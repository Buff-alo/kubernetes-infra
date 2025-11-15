## Create Namespace

```bash
kubectl create ns minio
```

## Add minio helm repo
```bash
helm repo add minio https://charts.min.io/
helm repo update
```

## Install Minio

```bash
helm install minio minio/minio \
  -n minio \
  -f minio-values.yaml 
```

## Get Credentials

```bash
export ROOT_USER=$(kubectl get secret --namespace minio minio -o jsonpath="{.data.root-user}" | base64 -d)
export ROOT_PASSWORD=$(kubectl get secret --namespace minio minio -o jsonpath="{.data.root-password}" | base64 -d)
echo $ROOT_USER
echo $ROOT_PASSWORD
```
