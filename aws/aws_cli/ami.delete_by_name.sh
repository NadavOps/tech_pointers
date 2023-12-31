#!/bin/bash

parse_arguments() {
  parse_arguments_help() {
    local script_name
    script_name="$(readlink -f $0 | rev | cut -d "/" -f1 | rev)"
    echo """
Usage:
  Find/ Delete AMIs and their snapshots + find public AMI current hard limit quota
  $script_name \\
    [-a](AMI name/s) \\
    [-s](number of latest images to save) \\
    [-d](dry run enabled) \\
    [-r](to set a specific regions (\"us-east-1 us-east-2\") else runs for all regions)
    [-h](help)
"""
  }
  local a s d r h o
  DRY_RUN="false"
  while getopts "a:s:dr:h" o; do
    case "$o" in
        h) parse_arguments_help; exit 0;;
        a) AMI_NAME="${OPTARG}";;
        s) SAVE_X_IMAGE="${OPTARG}";;
        d) DRY_RUN="true";;
        r) REGIONS="${OPTARG}";;
        *) parse_arguments_help; exit 1;;
    esac
  done

  echo "WARNING: dry run is set to: $DRY_RUN"
  if [[ -z "$REGIONS" ]]; then
    REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)
  fi
  if [[ -z "$SAVE_X_IMAGE" && "$DRY_RUN" == "false" ]]; then
    read -p "This will delete all matched AMIs. ctrl+c to cancel"
  fi
}

find_delete_amis_and_snapshots() {
  if [[ -z "$AMI_NAME" ]]; then
    echo "ERROR: ami name was not supplied"
    exit 1
  fi

  for region in $REGIONS; do
    echo "INFO: Region: $region"

    ami_ids=$(aws ec2 describe-images \
      --filters "Name=name,Values=$AMI_NAME" \
      --region "$region" \
      --query 'Images | sort_by(@, &CreationDate) | [].{ID: ImageId, Name: Name, CreationDate: CreationDate}')

    # ami_id=$(aws ec2 describe-images --region $region --filters "Name=name,Values=$AMI_NAME" --query "Images[0].ImageId" --output text)
    echo "INFO: AMI/s: $ami_ids"
    if [[ -z "$SAVE_X_IMAGE" ]]; then
      ami_ids=$(echo "${ami_ids}" | jq -r '.[].ID')
    else
      echo "DEBUG: Saving $SAVE_X_IMAGE AMI"
      if [[ ! $SAVE_X_IMAGE =~ ^[0-9]+$ ]]; then
          echo "ERROR: SAVE_X_IMAGE: $SAVE_X_IMAGE must be a number"
          exit 1
      fi
      # ami_ids=$(echo "${ami_ids}" | jq -r '.[:-1] | .[].ID')
      ami_ids=$(echo "${ami_ids}" | jq -r --arg SAVE_X_IMAGE "$SAVE_X_IMAGE" ".[:-($SAVE_X_IMAGE|tonumber)] | .[].ID")
    fi

    for ami_id in $ami_ids; do
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
    done
    echo "==== Next ===="
  done
}

parse_arguments "$@"
find_delete_amis_and_snapshots
