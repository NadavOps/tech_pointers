ASG_NAME=""
asg_instances_ids=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" \
    --query "AutoScalingGroups[0].Instances[].InstanceId" --output text)

for instance_id in $asg_instances_ids; do
    echo "$instance_id"
    instance_private_dns=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[].Instances[].NetworkInterfaces[0].PrivateDnsName' --output text)
    kubectl describe node $instance_private_dns | grep -i "Non-terminated Pods:" -A 10
done

for instance_id in $asg_instances_ids; do
    echo "$instance_id"
    instance_private_dns=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[].Instances[].NetworkInterfaces[0].PrivateDnsName' --output text)
    echo "Running: kubectl drain $instance_private_dns"
    kubectl drain $instance_private_dns
    echo "sleep 420"
    sleep 420
    echo "done sleep"
done
