
## Install Loki aggregator
```bash
helm upgrade --install loki grafana/loki \
  -n logging \
  -f loki-values.yaml
```