## Install Grafana 
```bash
helm upgrade --install grafana grafana/grafana \
  -n logging \
  -f grafana-values.yaml
```