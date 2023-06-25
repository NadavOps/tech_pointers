#!/bin/bash

# Specify the AMI name
ami_name="your ami name"

# Get a list of all AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Loop over each region
for region in $regions; do
  echo "Region: $region"

  ami_id=$(aws ec2 describe-images --region $region --filters "Name=name,Values=$ami_name" --query "Images[0].ImageId" --output text)
  echo "AMI: $ami_id"

  if [[ -n "$ami_id" && "$ami_id" != "None" ]]; then
    snapshot_ids=$(aws ec2 describe-images --region $region --image-ids $ami_id --query "Images[0].BlockDeviceMappings[].Ebs.SnapshotId" --output text)

    echo "Deregister $ami_id in the region $region."
    aws ec2 deregister-image --region $region --image-id $ami_id

    # Delete the associated snapshots
    for snapshot_id in $snapshot_ids; do
      echo "Deleting snapshot $snapshot_id in the region $region."
      aws ec2 delete-snapshot --region $region --snapshot-id $snapshot_id
    done

  else
    echo "AMI $ami_name does not exist in the region $region."
  fi

  echo "==== Next ===="
done
