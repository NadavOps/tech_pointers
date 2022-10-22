#!/bin/bash
source ~/.shellrc.d/bash_logging.sh
pattern="$1"
if [[ -z "$pattern" ]]; then
    bash_logging DEBUG "Pass a pattern to search for pvcs to delete"
    exit 1
fi

pvcs=$(kubectl get pvc | grep -e "$pattern" | awk '{print $1}')
bash_logging WARN "PVCs that will be checked for deletion"
for pvc in $pvcs; do
    bash_logging WARN $pvc
    unverified_pvcs+=("$pvc")
done

bash_logging INFO "To delete pvcs without validation just run the command:"
bash_logging WARN "kubectl delete pvc ${unverified_pvcs[*]}"

for pvc in $pvcs; do
    bash_logging DEBUG "Evaluating pvc: \"$pvc\""
    if kubectl describe pvc $pvc | grep "Used By:" | grep "<none>" &>/dev/null; then 
        bash_logging DEBUG "PVC is not mounted, added for deletion"
        verified_pvcs+=("$pvc")
    else
        bash_logging ERROR "PVC: \"$pvc\" is mounted, not added for deletion"
    fi
done

if [[ -z "$verified_pvcs" ]]; then
    bash_logging ERROR "No PVCS are found for deletion for the pattern \"$pattern\""
    exit 1
fi

bash_logging INFO "PVCs that were verified for deletion"
for pvc in "${verified_pvcs[@]}"
do
     bash_logging INFO "$pvc"
done

bash_logging WARN """Are you sure you want to delete the verified PVCS?
                              press any key if you do or CTRL+C to cancel"""
read

bash_logging INFO "Deleting the verified PVCS"
for pvc in "${verified_pvcs[@]}"
do
    kubectl delete pvc "$pvc" && \
    bash_logging WARN "PVC: \"$pvc\" was deleted" || \
    bash_logging ERROR "PVC: \"$pvc\" was not deleted"
done