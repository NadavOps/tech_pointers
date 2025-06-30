#!/bin/bash

parse_arguments() {
  parse_arguments_help() {
    local script_name
    script_name="$(readlink -f $0 | rev | cut -d "/" -f1 | rev)"
    echo """
Usage:
  $script_name \\
    [-k](Key pair name) \\
    [-r](Region) \\
    [-l](list aws key pairs) \\
    [-h](help)
"""
  }
  LIST_AWS_KEY_PAIRS_ENABLED="false"

  local a s d r h o
  while getopts "k:r:lh" o; do
    case "$o" in
        h) parse_arguments_help; exit 0;;
        k) KEY_NAME="${OPTARG}";;
        r) REGIONS="${OPTARG}";;
        l) LIST_AWS_KEY_PAIRS_ENABLED="true";;
        *) parse_arguments_help; exit 1;;
    esac
  done

  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/helpers.sh" # imports aws_profile_picker aws_get_available_regions
  if [[ -z "$AWS_PROFILE" ]]; then
    aws_profile_picker
  else
    aws_sts_get_caller_identity
  fi

  if [[ -z "$REGIONS" ]]; then
    REGIONS=$(aws_get_available_regions)
    echo "INFO: REGIONS was not set, using all regions: $REGIONS"
  else
    echo "INFO: REGIONS was set to: $REGIONS"
  fi  
}

upload_aws_key_pairs() {
    local region
    if [[ -z "$KEY_NAME" ]]; then
        echo "INFO: KEY_NAME was not set, no key to upload"
        return 0
    fi

    if [[ ! -f ~/.ssh/$KEY_NAME.pub ]]; then
        echo "INFO: Listing available public keys"
        ls -lah ~/.ssh/*.pub | sort
        echo "ERROR: ~/.ssh/$KEY_NAME.pub does not exist"
        exit 1
    fi

    for region in $REGIONS; do
        echo "INFO: Region: $region"
        aws ec2 import-key-pair --region $region --key-name $KEY_NAME --public-key-material fileb://~/.ssh/$KEY_NAME.pub && \
            echo "INFO: Key pair $KEY_NAME was uploaded to the region $region"
        echo "========"
    done
}

list_aws_key_pairs() {
    local region
    if [[ "$LIST_AWS_KEY_PAIRS_ENABLED" == "false" ]]; then
        return 0
    fi

    echo """INFO: LIST_AWS_KEY_PAIRS_ENABLED is: \"$LIST_AWS_KEY_PAIRS_ENABLED\". 
            Starting listing aws key pairs"""
    for region in $REGIONS; do
        echo "INFO: Region: $region"
        aws ec2 describe-key-pairs --region $region --query "KeyPairs[].KeyName" --output text
        echo "========"
    done
    echo "INFO: Done listing aws key pairs"
}

parse_arguments "$@"
list_aws_key_pairs
upload_aws_key_pairs


# find_delete_amis_and_snapshots
