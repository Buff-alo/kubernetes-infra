# Elastick Search Installation

## Installation Commands

```bash
    helm install elasticsearch elastic/elasticsearch \
        -n logging \
        --create-namespace \
        --version 8.5.1 \
        -f es-values.yaml
    #Ensure logging namespace exits

```

## Username Retrieval
```bash
    kubectl get secrets --namespace=logging elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
```