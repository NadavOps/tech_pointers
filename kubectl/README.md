# kubectl

### Table of Content
* [Commands](#commands)
* [Links](#links)

## Commands
```
# secret
kubectl get secret <secret_name> --template={{.data.password}} | base64 -d | pbcopy

# logs
kubectl logs --timestamps --tail 200 -f <pod_name> --> adding timestamps, listens on stdout, and print last 200 lines

# label node
kubectl label nodes node_name label_key=label_value
```

## Links

* [Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/).
* [Commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands).
