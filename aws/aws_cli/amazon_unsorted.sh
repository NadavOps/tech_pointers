#!/bin/bash
verify_aws_profile() {
  local all_profiles profile_name
  all_profiles="$1"
  profile_name="$2"
  if ! echo "$all_profiles" | grep -w -q "$profile_name"; then
    echo "ERROR: aws profile $profile_name was not found in your $HOME/.aws/config, make sure to have it and configure it correctly"
    exit 1
  fi
}

verify_profiles() {
  local all_profiles
  all_profiles=$(aws configure list-profiles)
  verify_aws_profile "$all_profiles" "profile_name_to_check"
}
