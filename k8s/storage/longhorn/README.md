# Longhorn Storage backend installation

```bash
    kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.10.0/deploy/longhorn.yaml
```

## Configure to target specific labels

```bash
    kubectl -n longhorn-system patch daemonset longhorn-manager \
        --type='json' -p='[{"op":"add","path":"/spec/template/spec/nodeSelector","value":{"storage":"longhorn"}}]'
```

## Apply Ingress/Ingressroute

```bash
    kubectl apply -f longhorn-ui-ingress.yaml
```

## Uninstall
```bash
    kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/v1.10.0/deploy/longhorn.yaml 
    for crd in $(kubectl get crd -o name | grep longhorn); do kubectl patch $crd -p '{"metadata":{"finalizers":[]}}' --type=merge; done 

    #If namespace is stuck at terminating, Try this
    kubectl get namespace longhorn-system -o json \
    | jq 'del(.spec.finalizers)' \
    | kubectl replace --raw /api/v1/namespaces/longhorn-system/finalize -f -

````
