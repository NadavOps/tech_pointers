#!/bin/bash

parse_arguments() {
  parse_arguments_help() {
    local script_name
    script_name="$(readlink -f $0 | rev | cut -d "/" -f1 | rev)"
    echo """
Usage:
  Find/ Delete AMIs and their snapshots + find public AMI current hard limit quota
  $script_name \\
    [-a](AMI name) \\
    [-d](dry run enabled) \\
    [-l](Find public AMI limit) \\
    [-h](help)
"""
  }
  local a d l h o
  DRY_RUN="false"
  while getopts "a:dlh" o; do
    case "$o" in
        h) parse_arguments_help; exit 0;;
        a) AMI_NAME="${OPTARG}";;
        d) DRY_RUN="true";;
        l) LIMIT_FIND_ENABLED="true";;
        *) parse_arguments_help; exit 1;;
    esac
  done

  echo "WARNING: dry run is set to: $DRY_RUN"
  REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)
}

find_service_quota_limit() {
  if [[ "$LIMIT_FIND_ENABLED" == "true" ]]; then
    echo """INFO: To find other limits here some commands that can help:
      1. Find your desired service code:
          aws service-quotas list-aws-default-service-quotas --service-code ec2 | jq -r ".Quotas"
      2. Find your desired quota code for service code
          aws service-quotas list-aws-default-service-quotas --service-code ec2
      3. Find your quota limit
          aws service-quotas get-service-quota --service-code ec2 --quota-code "L-0E3CBAB9"
      """
    for region in $REGIONS; do
      echo "INFO: Region $region"
      echo "INFO: public amis current limit"
      aws service-quotas get-service-quota --service-code ec2 --quota-code "L-0E3CBAB9" --region "$region" --output json | jq -r ".Quota.Value"
      echo "INFO: Current amount of public amis"
      # echo aws ec2 describe-images --filters "Name=is-public,Values=true" --region "$region" --query 'length(Images[])'
      # aws ec2 describe-images --owners self amazon --filters "Name=is-public,Values=true" --region <your-region> --output text | wc -l
      echo "====="
    done
  fi          
}

find_delete_amis_and_snapshots() {
  if [[ -z "$AMI_NAME" ]]; then
    echo "INFO: ami name was not supplied"
    exit 0
  fi

  for region in $REGIONS; do
    echo "INFO: Region: $region"

    ami_id=$(aws ec2 describe-images --region $region --filters "Name=name,Values=$AMI_NAME" --query "Images[0].ImageId" --output text)
    echo "INFO: AMI: $ami_id"

    if [[ -n "$ami_id" && "$ami_id" != "None" ]]; then
      snapshot_ids=$(aws ec2 describe-images --region $region --image-ids $ami_id --query "Images[0].BlockDeviceMappings[].Ebs.SnapshotId" --output text)
      if [[ "$DRY_RUN" != "true" ]]; then
        echo "INFO: Deregister $ami_id in the region $region."
        aws ec2 deregister-image --region $region --image-id $ami_id
      fi

      # Delete the associated snapshots
      for snapshot_id in $snapshot_ids; do
        echo "DEBUG: found $snapshot_id in the region $region."
        if [[ "$DRY_RUN" != "true" ]]; then
          echo "INFO: Deleting snapshot $snapshot_id in the region $region."
          aws ec2 delete-snapshot --region $region --snapshot-id $snapshot_id
        fi
      done

    else
      echo "INFO: AMI $ami_name does not exist in the region $region."
    fi

    echo "==== Next ===="
  done
}

parse_arguments "$@"
find_service_quota_limit
find_delete_amis_and_snapshots
