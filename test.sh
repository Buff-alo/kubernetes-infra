for pod in $(kubectl get pod | grep node ); do echo "Deleting node-debugger pods"; kubectl delete $pod; done

# 1. Ensure old pods are deleted
kubectl delete pod test-pod-1 test-pod-2 --ignore-not-found=true

# 2. Run new pods to pick up any network changes
kubectl run test-pod-1 --image=arunvelsriram/utils --overrides='{"spec": {"nodeName": "oci-kls-controlplane-1"}}' -- sleep 3600
kubectl run test-pod-2 --image=arunvelsriram/utils --overrides='{"spec": {"nodeName": "oci-kls-worker-1"}}' -- sleep 3600

# 3. Wait until both pods are Running and Ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod/test-pod-1 --timeout=120s
kubectl wait --for=condition=ready pod/test-pod-2 --timeout=120s
echo "Pods are ready."

# 4. Get pod IPs
POD1_IP=$(kubectl get pod test-pod-1 -o jsonpath='{.status.podIP}')
echo "POD1_IP: $POD1_IP"
POD2_IP=$(kubectl get pod test-pod-2 -o jsonpath='{.status.podIP}')
echo "POD2_IP: $POD2_IP"

# 5. Test connectivity (This should now succeed)
echo "Testing connectivity: Pod 1 (Control Plane) -> Pod 2 (Worker 1)"
kubectl exec test-pod-1 -- ping -c 3 $POD2_IP
echo "Testing connectivity: Pod 2 (Worker 1) -> Pod 1 (Control Plane)"
kubectl exec test-pod-2 -- ping -c 3 $POD1_IP


CILIUM_POD=$(kubectl get pods -n kube-system -l k8s-app=cilium -o jsonpath='{.items[?(@.spec.nodeName=="oci-kls-controlplane-1")].metadata.name}')
echo "Starting Cilium Monitor (DROP events only) on Control Plane. Run 'kubectl exec test-pod-1 -- ping -c 3 ' in a new window."
kubectl exec -it $CILIUM_POD -n kube-system -- cilium monitor -t drop


#!/bin/bash
echo "=== POD TO INTERNET PING ==="
kubectl exec test-pod-1 -- ping -c 3 8.8.8.8

echo "=== DNS RESOLUTION ==="
kubectl exec test-pod-1 -- nslookup google.com

echo "=== DNS RESOLUTION in cluster ==="
kubectl exec test-pod-1 -- nslookup kubernetes.default

echo "=== API SERVER ACCESS ==="
kubectl exec test-pod-1 -- curl -k https://100.118.120.5:6443/version

echo "=== CILIUM STATUS ==="
kubectl exec -n kube-system ds/cilium -- cilium status

echo "=== TRIVY SERVER ACCESS ==="
kubectl exec -n kube-system test-pod-1 -- curl -v --connect-timeout 5 http://100.102.159.43:4954/healthz
