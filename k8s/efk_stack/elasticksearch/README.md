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
    kubectl get secret elasticsearch -n logging -o jsonpath="{.data.elasticsearch-password}" | base64 --decode
```