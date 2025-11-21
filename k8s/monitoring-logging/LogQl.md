# LogQL Cheatsheet: K3s PLG Stack (Multi-Cloud)

This reference guide is tailored for the K3s + Tailscale + PLG Stack environment. It assumes the following custom labels are active:
- `hostname`: The Node name (e.g., AWS, OCI, GCP nodes).
- `service`: The container/app name.
- `source`: Used for external logs (e.g., `external-docker`).

---

## 🔍 1. Discovery & Selectors
*How to find the logs you need.*

| Target | LogQL Query | Description |
| :--- | :--- | :--- |
| **Namespace** | `{namespace="logging"}` | Show all logs in the `logging` namespace. |
| **Specific App** | `{service="movie-app"}` | Filter by the container name (mapped via Promtail). |
| **Specific Host** | `{hostname="oci-kls-worker-1"}` | Isolate logs from a specific cloud node. |
| **External Docker**| `{source="external-docker"}` | Logs from non-Kubernetes servers (Tailnet nodes). |
| **Complex Select**| `{app="loki", namespace="logging"}` | Combine multiple labels for precision. |

---

## 🔎 2. Text Search & Filtering
*Grep your logs for specific keywords.*

### Line Contains (`|=`)
Find lines containing "error".
```logql
{namespace="default"} |= "error"