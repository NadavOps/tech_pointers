#!/bin/bash

aws_sts_get_caller_identity() {
    echo "INFO: Running as AWS profile: ${AWS_PROFILE:-default}"
    aws sts get-caller-identity
}

aws_profile_picker() {
    local profile_number
    echo "INFO: Available AWS profiles:"
    aws configure list-profiles | sort | nl

    echo "INFO: Select an AWS profile by entering the corresponding number:"
    read -p "Enter profile number (or press Enter to use the default profile): " profile_number

    if [[ -n "$profile_number" ]]; then
        AWS_PROFILE=$(aws configure list-profiles | sed -n "${profile_number}p")
        export AWS_PROFILE
    fi

    aws_sts_get_caller_identity
    echo -e "\nINFO: Press Enter to continue or Ctrl+C to cancel."
    read
}

aws_get_available_regions() {
    aws ec2 describe-regions --all-regions \
        --query "Regions[?OptInStatus=='opt-in-not-required' || OptInStatus=='opted-in'].RegionName" \
        --output text
}
