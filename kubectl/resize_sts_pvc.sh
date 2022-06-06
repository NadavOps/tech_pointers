#!/bin/bash
source ~/.shellrc.d/bash_logging.sh
statefulset_name="$1"
new_size="$2" ## pay attention this script does not handle the cases where we increase from one unit to another, EG -> Mi to Gi
if [[ -z "$statefulset_name" ]]; then
    bash_logging ERROR "pass a statefulset_name as the 1st param to identify its pvcs and resize them"
    exit 1
fi

if [[ -z "$new_size" ]]; then
    bash_logging ERROR "pass a new_size as the 2nd param to resize pods pvcs"
    exit 1
fi

if [[ ! $new_size =~ ^[0-9]+$ ]]; then
    bash_logging ERROR "2nd parameter \"new_size\" must be an integer"
    exit 1
fi

if kubectl get sts "$statefulset_name" &> /dev/null; then
    bash_logging INFO "\"$statefulset_name\" was found, continue"
else
    bash_logging ERROR "\"$statefulset_name\" was not found, re-enter a valid statefulset_name"
    exit 1
fi

pvcs=$(kubectl get pvc | grep "$statefulset_name" | awk '{print $1}')
bash_logging INFO "PVCs that will be checked for resizing"
for pvc in $pvcs; do
    bash_logging INFO "$pvc"
done

for pvc in $pvcs; do
    bash_logging DEBUG "Evaluating pvc: \"$pvc\""
    mounting_pod=$(kubectl describe pvc $pvc | grep 'Mounted By:' | awk '{print $3}')
    verified_sts=$(kubectl get -o jsonpath='{.metadata.ownerReferences[0].name}' pod $mounting_pod)
    if [[ "$verified_sts" != "$statefulset_name" ]]; then
        bash_logging ERROR "PVC: \"$pvc\" is not related to STS: \"$statefulset_name\", moving to next PVC"
        continue
    fi
    pvc_size_raw=$(kubectl get -o jsonpath='{.spec.resources.requests.storage}' pvc $pvc)
    pvc_size_number=$(echo $pvc_size_raw | sed 's/[a-zA-Z]//g')
    if [[ $new_size -le $pvc_size_number ]]; then
        bash_logging ERROR "PVC: \"$pvc\" size \"$pvc_size_number\" is equal/bigger then the desired new size \"$new_size\""
        continue
    fi
    pvc_storage_class=$(kubectl get -o jsonpath='{.spec.storageClassName}' pvc $pvc)
    storage_class_expansion_enabled=$(kubectl get -o jsonpath='{.allowVolumeExpansion}' sc $pvc_storage_class)
    if [[ "$storage_class_expansion_enabled" != "true" ]]; then
        bash_logging ERROR "SC: \"$pvc_storage_class\" storage_class_expansion_enabled \"$storage_class_expansion_enabled\" is not true"
        continue
    fi    
    verified_pvcs+=("$pvc")
done

if [[ -z "$verified_pvcs" ]]; then
    bash_logging ERROR "No PVCS were found to be resized, check params/ script output to further investigate"
    exit 1
fi

bash_logging INFO "PVCs that were verified for resizing"
for pvc in "${verified_pvcs[@]}"
do
     bash_logging INFO "$pvc"
done

bash_logging WARN """Are you sure you want to run the following?
                              kubectl delete sts --cascade=false $statefulset_name
                              later on patch the PVCs with size of $new_size
                              press any key if you do or CTRL+C to cancel"""
read
bash_logging WARN "running kubectl delete sts --cascade=false $statefulset_name"
kubectl delete sts --cascade=false $statefulset_name

bash_logging INFO "Patching verified PVCs with new size"
for pvc in "${verified_pvcs[@]}"
do
    pvc_size_raw=$(kubectl get -o jsonpath='{.spec.resources.requests.storage}' pvc $pvc)
    pvc_new_size_raw=$new_size
    pvc_new_size_raw+=$(echo $pvc_size_raw | sed 's/[0-9]//g')
    bash_logging DEBUG "patching pvc: \"$pvc\" from pvc_size_raw \"$pvc_size_raw\" to \"$pvc_new_size_raw\""
    kubectl patch -p '{"spec": {"resources": {"requests": {"storage": "'$pvc_new_size_raw'"}}}}' pvc $pvc
done
