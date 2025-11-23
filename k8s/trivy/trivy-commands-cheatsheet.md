# Trivy Operator Command Cheat Sheet

A quick reference for interacting with Trivy Vulnerability Reports in Kubernetes.

## 🔍 Summary Views

### List all reports in all namespaces
Get a high-level overview of every scan report generated in the cluster.
```bash
kubectl get vulnerabilityreports -A -o wide
```

### Clean Summary Table (Custom Columns)
```bash
kubectl get vulns -A -o custom-columns=\
"NAMESPACE:.metadata.namespace",\
"NAME:.metadata.name",\
"CRITICAL:.report.summary.criticalCount",\
"HIGH:.report.summary.highCount",\
"MEDIUM:.report.summary.mediumCount",\
"AGE:.metadata.creationTimestamp"
```
### Sort by Critical Severity
```bash
kubectl get vulns -A --sort-by='.report.summary.criticalCount'
```

## 🧐 Inspecting Specific Reports

### Find a report for a specific Deployment
```bash
kubectl get vulns -n <namespace> -l trivy-operator.resource.name=grafana
```
### View full report details (JSON)
```bash
kubectl get vuln <report-name> -n <namespace> -o json
```

## 🛠 Advanced Filtering (using jq)

###
```bash
kubectl get vuln <report-name> -n <namespace> -o json | \
  jq '.report.vulnerabilities[] | select(.severity=="CRITICAL") | {ID: .vulnerabilityID, Pkg: .pkgName, FixedIn: .fixedVersion, Title: .title}'
```
### Find "Fixable" Vulnerabilities
```bash
kubectl get vuln <report-name> -n <namespace> -o json | \
  jq '.report.vulnerabilities[] | select(.fixedVersion != "") | .vulnerabilityID + " can be fixed in " + .fixedVersion'
```

## 🔄 Manual Actions

### Trigger an Immediate Re-Scan
```bash
#The operator normally scans every 24h. Force a re-scan immediately by annotating the Pod.

# 1. Delete the old report (optional but recommended):
kubectl delete vuln <report-name> -n <namespace>

# 2.Annotate the Pod:
kubectl annotate pod <pod-name> -n <namespace> \
  trivy-operator.aquasecurity.github.io/report-ttl=1s --overwrite
```
## 🛡 Other Security Reports

### Config Audits (Infrastructure as Code)
```bash
# Checks for misconfigurations (e.g., running as root, privileged containers).
kubectl get configauditreports -A
# Short alias:
kubectl get configaudits -A
```
### Exposed Secrets
```bash
# Checks environment variables for hardcoded passwords or API keys.
kubectl get exposedsecretreports -A
```
### Cluster Compliance (NSA / CIS)
```bash
# Checks if the cluster meets compliance benchmarks.
kubectl get clustercompliancereports -A
```