#!/bin/bash

# Get list of all regions
profile="${1:-default}"
echo "You are using profile \"$profile\""
regions=$(aws ec2 describe-regions --query 'Regions[*].[RegionName]' --output text --profile "$profile")

# Get a list of all VPCs
vpcs=$(aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId]' --output text --profile "$profile")

vpcs_with_flow_logs=()
for region in $regions
do
  echo "Region: $region"
  
  # Get a list of all VPCs in the current region
  vpcs=$(aws ec2 describe-vpcs --region $region --query 'Vpcs[*].[VpcId]' --output text --profile "$profile")
  
  # Loop through each VPC
  for vpc in $vpcs
  do    
    # Check if VPC flow logs are enabled for the current VPC
    flow_logs=$(aws ec2 describe-flow-logs --region $region --filter "Name=resource-id,Values=$vpc" --query 'FlowLogs[*].[FlowLogId]' --output text --profile "$profile")
    
    if [ -n "$flow_logs" ]
    then
      echo "VPC \"$vpc\" has flowlogs"
      vpcs_with_flow_logs+=("$region:$vpc")
    fi
  done
  echo "===== Next Region ====="
done

# Print all VPCs with flow logs enabled
echo "VPCs with flow logs enabled:"
for vpc in "${vpcs_with_flow_logs[@]}"
do
  echo $vpc
done