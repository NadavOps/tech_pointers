#!/bin/bash
operation="$1"
if [[ "$operation" != "delete" ]] && [[ "$operation" != "apply" ]]; then
    echo "Asd"
    exit 1
fi

# cat <<EOF | kubectl "$operation" -f -
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: some-nginx-test-deployment
#   namespace: namespace
#   labels:
#     app: some-nginx-test-deployment
#   annotations:
#     kubernetes.io/psp: eks.privileged
# spec:
#   replicas: 3
#   selector:
#     matchLabels:
#       app: unique-match-test
#   template:
#     metadata:
#       labels:
#         app: unique-match-test
#     spec:
#       containers:
#       - name: some-test-nginx-container
#         image: nginx:1.14.2
#         ports:
#         - containerPort: 80
#       tolerations:
#       - key: "somekey"
#         operator: "Equal"
#         value: "somevalue"
#         effect: "NoSchedule"
#       nodeSelector:
#         somekey: somevalue
#       affinity:
#         podAntiAffinity:
#           preferredDuringSchedulingIgnoredDuringExecution:
#           - weight: 100
#             podAffinityTerm:
#               labelSelector:
#                 matchExpressions:
#                 - key: somekey
#                   operator: In
#                   values:
#                   - somevalue
#               topologyKey: kubernetes.io/hostname
#           - weight: 100
#             podAffinityTerm:
#               labelSelector:
#                 matchExpressions:
#                 - key: app
#                   operator: In
#                   values:
#                   - unique-match-test
#               topologyKey: topology.kubernetes.io/zone
# EOF

cat <<EOF | kubectl "$operation" -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-test
  labels:
    app: nginx-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-test
  template:
    metadata:
      labels:
        app: nginx-test
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      restartPolicy: Never
EOF
