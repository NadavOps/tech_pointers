#!/bin/bash
set -e

parse_arguments() {
  parse_arguments_help() {
    local script_name
    script_name="$(readlink -f $0 | rev | cut -d "/" -f1 | rev)"
    echo """
Usage:
  Find/ Delete LaunchTemplates
  $script_name \\
    [-k](Tag key) \\
    [-v](Tag value) \\
    [-r](Specific region, example us-east-1) \\
    [-d](dry run enabled) \\
    [-h](help)
"""
  }
  local k v p r d h o
  DRY_RUN="false"
  while getopts "k:v:p:r:dh" o; do
    case "$o" in
        h) parse_arguments_help; exit 0;;
        k) TAG_KEY="${OPTARG}";;
        v) TAG_VALUE="${OPTARG}";;
        p) PROFILE="${OPTARG}";;
        r) REGIONS="${OPTARG}";;
        d) DRY_RUN="true";;
        *) parse_arguments_help; exit 1;;
    esac
  done

  echo "WARNING: dry run is set to: $DRY_RUN"
  if [[ -z "$REGIONS" ]]; then
    REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)
  fi
  if [[ -n "$PROFILE" ]]; then
    echo "WARNING: Using profile: $PROFILE"
    export AWS_PROFILE="$PROFILE"
  fi
  echo "WARNING: Running as:" && aws sts get-caller-identity
}

parse_arguments "$@"

for region in $REGIONS; do
    echo "INFO: Region $region"
    launch_template_ids=$(aws ec2 describe-launch-templates \
        --region $region \
        --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" \
        --query "LaunchTemplates[*].LaunchTemplateId" --output text)
    for id in $launch_template_ids; do
        launch_template_name=$(aws ec2 describe-launch-templates \
            --region $region \
            --launch-template-ids $LAUNCH_TEMPLATE_ID \
            --query "LaunchTemplates[0].LaunchTemplateName" --output text)
        echo "Delete: launch template ID: $id ($launch_template_name)"
        if [[ "$DRY_RUN" == "false" ]]; then
            aws ec2 delete-launch-template --region $region --launch-template-id $id
        fi        
        echo "--------------------------"
    done
done
