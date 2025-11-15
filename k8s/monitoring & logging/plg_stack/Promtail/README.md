## Install Promtail (Log Collector)
```bash
helm upgrade --install promtail grafana/promtail \
  -n logging \
  -f promtail-values.yaml
```