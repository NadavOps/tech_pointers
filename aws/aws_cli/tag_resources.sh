#!/bin/bash
ASG_NAMES=(
"ASG NAME 1"
"ASG NAME 2"
"ASG NAME 3"
)
TAG_KEY="key"
TAG_VALUE="value"

instance_id_list=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "${ASG_NAMES[@]}" --query 'AutoScalingGroups[].Instances[].InstanceId' | jq -r ".[]")

instance_id_list_format=$(echo $instance_id_list | tr " " ",")

volume_id_list=$(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values="$instance_id_list_format" | jq -r ".Volumes[].VolumeId")

for volume_id in $volume_id_list; do aws ec2 create-tags --resources $volume_id --tags Key=$TAG_KEY,Value=$TAG_VALUE; done
for instance_id in $instance_id_list; do aws ec2 create-tags --resources $instance_id --tags Key=$TAG_KEY,Value=$TAG_VALUE; done