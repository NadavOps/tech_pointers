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
    [-r](to set a specific regions (\"us-east-1 us-east-2\") else runs for all regions) \\
    [-p](Public AMI: limit value qutoa request) \\
    [-d](dry run) \\
    [-h](help)
"""
  }
  local l b r p d h o
  while getopts "lb:r:p:dh" o; do
    case "$o" in
        h) parse_arguments_help; exit 0;;
        l) FIND_LIMIT_ENABLED="true";;
        b) IMAGE_PUBLIC_STATE="${OPTARG}";;
        r) REGIONS="${OPTARG}";;
        p) PUBLIC_AMI_QUOTA_VALUE_REQUEST="${OPTARG}";;
        d) DRY_RUN="true";;
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

  if [[ -n "$DRY_RUN" ]]; then
    echo "DEBUG: DRY_RUN is enabled"
  else
    echo "WARN: DRY_RUN is not enabled"
  fi
}

dry_run_enabled() {
  if [[ -n "$DRY_RUN" ]]; then
    return 0
  else
    return 1
  fi
}

quota_request() {
  local service_code quota_code value_to_request quota_current_value user_input
  service_code="$1"
  quota_code="$2"
  value_to_request="$3"
  quota_current_value="$4"
  if [[ -z "$value_to_request" ]]; then
    return 0
  fi
  # We use bc to compare the two floating-point numbers.
  # The echo "$value_to_request == $quota_current_value" | bc -l command calculates the comparison, and if it evaluates to 1
  # it means the values are equal. If it evaluates to 0, the values are not equal.
  if (( $(echo "$value_to_request == $quota_current_value" | bc -l) )); then
    echo "INFO: quota code \"$quota_code\" in service \"$service_code\" is set to \"$quota_current_value\". no reason to ask to set for \"$value_to_request\""
    return 0
  fi
  echo "DEBUG: Request to set value \"$value_to_request\" for code \"$quota_code\""
  dry_run_enabled && return 0
  quota_cases_requests=$(aws service-quotas list-requested-service-quota-change-history \
    --service-code "$service_code" --region "$region" | jq --arg quota "$quota_code" '.RequestedQuotas | map(select(.QuotaCode == $quota))')
  if [[ -n "$quota_cases_requests" ]]; then
    echo "A request had been made:"
    echo "$quota_cases_requests"
  fi
  read -p "Do you want to proceed? (y/n): " user_input
  if [ "$user_input" = "y" ]; then
    echo "Proceeding"
  else
    echo "Not proceeding"
    return 0
  fi
  aws service-quotas request-service-quota-increase --service-code "$service_code" --quota-code "$quota_code" --desired-value "$value_to_request" --region "$region"
}

find_service_quota_limit() {
  local region quota_current_value
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
      quota_current_value=$(aws service-quotas get-service-quota --service-code ec2 --quota-code "L-0E3CBAB9" --region "$region" --output json | jq -r ".Quota.Value")
      echo "INFO: public amis current limit: $quota_current_value"
      quota_request "ec2" "L-0E3CBAB9" "$PUBLIC_AMI_QUOTA_VALUE_REQUEST" "$quota_current_value"
      # echo "INFO: Current amount of public amis"
      # aws ec2 describe-images --owners self --query 'Images[?Public==`true`]' --region "$region" --output json | jq length
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
        dry_run_enabled && continue
        aws ec2 disable-image-block-public-access --region "$region"
      fi
      if [[ "$IMAGE_PUBLIC_STATE" == "enable" ]] && [[ "$image_block_public_access_state" != "block-new-sharing" ]]; then
        echo "INFO: Enable block public state"
        dry_run_enabled && continue
        aws ec2 enable-image-block-public-access --image-block-public-access-state "block-new-sharing" --region "$region"
      fi
      echo "====="
    done
  fi          
}

parse_arguments "$@"
find_service_quota_limit
find_image_public_state
