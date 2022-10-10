# baseline networking: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/general-purpose-instances.html#general-purpose-network-performance
aws ec2 describe-instance-types \
    --filters "Name=instance-type,Values=c5.*" \
    --query "InstanceTypes[].[InstanceType, NetworkInfo.NetworkPerformance]" \
    --output table

# Get private Ips of ec2 based on tag name
tag_key="Name"
tag_value=""

aws ec2 describe-instances \
--filters "Name=tag:$tag_key,Values=$tag_value" | jq -r '.Reservations[].Instances[].PrivateIpAddress'


for int_ip in $(aws ec2 describe-instances \
--filters "Name=tag:$tag_key,Values=$tag_value" | jq -r '.Reservations[].Instances[].PrivateIpAddress'); do
    echo $int_ip
    ssh $int_ip df -h
done
