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


# Get ami_id and info based on private_ip
#!/bin/bash
private_ip="$1"

ami_id=$(aws ec2 describe-instances \
  --filters "Name=private-ip-address,Values=$private_ip" \
  --query 'Reservations[].Instances[].ImageId' \
  --output text)

if [ -n "$ami_id" ]; then
  echo "AMI ID: $ami_id"

  aws ec2 describe-images \
    --image-ids "$ami_id" \
    --query 'Images[].[CreationDate, Tags]' \
    --output text
else
  echo "No AMI found for the provided private IP: $private_ip"
fi
