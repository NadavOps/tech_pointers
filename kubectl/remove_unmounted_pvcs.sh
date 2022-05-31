#!/bin/bash
source ~/.shellrc.d/bash_logging.sh
pattern="$1"
if [[ -z "$pattern" ]]; then
    bash_logging DEBUG "pass a pattern to search for pvcs to delete"
    exit 1
fi

pvcs=$(kubectl get pvc | grep "$pattern" | awk '{print $1}')
bash_logging WARN "pvcs that will be checked for deletion"
for pvc in $pvcs; do
    bash_logging WARN $pvc
done

for pvc in $pvcs; do
    bash_logging DEBUG "Evaluating pvc: \"$pvc\""
    if kubectl describe pvc $pvc | grep "Mounted By:" | grep "<none>" &>/dev/null; then 
        bash_logging WARN "PVC is not mounted, deleting"
        kubectl delete pvc "$pvc"
        bash_logging WARN "PVC: \"$pvc\" was deleted"
    else
        bash_logging ERROR "PVC: \"$pvc\" is mounted, not deleting"
    fi
    bash_logging DEBUG "Moving from PVC: \"$pvc\" to the next"
    bash_logging DEBUG "====================================="
done