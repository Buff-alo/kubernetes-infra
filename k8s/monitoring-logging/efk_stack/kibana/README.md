# Kibana Installation

## Installation Commands

```bash
    helm install kibana bitnami/kibana \
  -n logging \
  --set elasticsearch.hosts[0]=elasticsearch.logging.svc.cluster.local \
  --set service.type=NodePort
```