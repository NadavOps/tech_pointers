# kubectl

### Table of Content
* [Commands](#commands)
* [Code Snippets](#code-snippets)
* [Links](#links)

## Commands
```
# secret
kubectl get secret <secret_name> --template={{.data.password}} | base64 -d | pbcopy

# logs
kubectl logs --timestamps --tail 200 -f <pod_name> --> adding timestamps, listens on stdout, and print last 200 lines

# label node
kubectl label nodes node_name label_key=label_value

# External metric API
kubectl get --raw /apis/external.metrics.k8s.io/v1beta1 | jq . | grep -i -A 20 <metric_name>
kubectl get --raw /apis/external.metrics.k8s.io/v1beta1/namespaces/default/<metric_name>
kubectl get --raw /apis/external.metrics.k8s.io/v1beta1/namespaces/default/pods/*/<metric_name>
```

## Code Snippets
```bash
namespace_prefix="CHANGE_HERE"
kubectl get namespaces --no-headers | awk '$1 ~ "^'"$namespace_prefix"'" { print $1 }' | xargs kubectl delete namespace
```

## Links

* [Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/).
* [Commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands).
* [Debugging cert manager](https://hackmd.io/@maelvls/debug-cert-manager-webhook)
