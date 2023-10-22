#!/bin/bash

parse_arguments() {
  parse_arguments_help() {
    local script_name
    script_name="$(readlink -f $0 | rev | cut -d "/" -f1 | rev)"
    echo """
Usage:
  Find/ Delete AMIs and their snapshots + find public AMI current hard limit quota
  $script_name \\
    [-l](Find public AMI limit) \\
    [-b](Find/Set image block public access state. <get, enable(Block sharing), disable(Enable sharing)>) \\
    [-r](to set a specific regions (\"us-east-1 us-east-2\") else runs for all regions)
    [-h](help)
"""
  }
  local l b r h o
  DRY_RUN="false"
  while getopts "lb:r:h" o; do
    case "$o" in
        h) parse_arguments_help; exit 0;;
        l) FIND_LIMIT_ENABLED="true";;
        b) IMAGE_PUBLIC_STATE="${OPTARG}";;
        r) REGIONS="${OPTARG}";;
        *) parse_arguments_help; exit 1;;
    esac
  done

  if [[ -z "$REGIONS" ]]; then
    REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)
  fi

  if [[ -n "$IMAGE_PUBLIC_STATE" ]]; then
    if [[ "$IMAGE_PUBLIC_STATE" != "get" ]] && [[ "$IMAGE_PUBLIC_STATE" != "enable" ]] && [[ "$IMAGE_PUBLIC_STATE" != "disable" ]]; then
      echo "ERROR: IMAGE_PUBLIC_STATE is \"$IMAGE_PUBLIC_STATE\" and can be one of <get, enable, disable>"
      parse_arguments_help
      exit 1
    fi
  fi
}

find_service_quota_limit() {
  if [[ "$FIND_LIMIT_ENABLED" == "true" ]]; then
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

find_image_public_state() {
  if [[ "$IMAGE_PUBLIC_STATE" == "get" ]] || [[ "$IMAGE_PUBLIC_STATE" == "enable" ]] || [[ "$IMAGE_PUBLIC_STATE" == "disable" ]]; then
    echo "INFO: IMAGE_PUBLIC_STATE is \"$IMAGE_PUBLIC_STATE\""
    for region in $REGIONS; do
      echo "INFO: Region $region"
      image_block_public_access_state=$(aws ec2 get-image-block-public-access-state --region "$region" --output json | jq -r ".ImageBlockPublicAccessState")
      echo "INFO: image_block_public_access_state is \"$image_block_public_access_state\""
      if [[ "$IMAGE_PUBLIC_STATE" == "disable" ]] && [[ "$image_block_public_access_state" != "unblocked" ]]; then
        echo "INFO: Disable block public state"
        aws ec2 disable-image-block-public-access --region "$region"
      fi
      if [[ "$IMAGE_PUBLIC_STATE" == "enable" ]] && [[ "$image_block_public_access_state" != "block-new-sharing" ]]; then
        echo "INFO: Enable block public state"
        aws ec2 enable-image-block-public-access --image-block-public-access-state "block-new-sharing" --region "$region"
      fi
      echo "====="
    done
  fi          
}

parse_arguments "$@"
find_service_quota_limit
find_image_public_state
