#!/bin/bash
# can add some more from this article https://hystax.com/the-quickest-way-to-get-a-list-of-public-buckets-in-aws-to-enhance-your-security/
source $HOME/.shellrc.d/bash_logging.sh
aws_profiles=( "$1" "$2" )
if [[ -z "$aws_profiles" ]]; then
    bash_logging ERROR "supply 2 parameters, each an aws profile name"
    aws configure list-profiles
    exit 1
fi
error_buckets=()
most_likely_public=()
for aws_profile in ${aws_profiles[@]}; do
    for s3_bucket in $(aws s3 ls --profile "$aws_profile" | awk '{print $3}'); do
        bash_logging DEBUG "aws s3api get-public-access-block --profile $aws_profile --bucket $s3_bucket"
        aws_json_response=$(aws s3api get-public-access-block --profile "$aws_profile" \
            --bucket "$s3_bucket" 2> /dev/null) || error_buckets+=("$s3_bucket")
        check_public_block=$(echo "$aws_json_response" | jq -r ".PublicAccessBlockConfiguration[] | select(.|not)" | sort -u)
        if [[ "$check_public_block" == "false" ]]; then
            most_likely_public+=("$s3_bucket")
        fi
    done

    bash_logging INFO "output for $aws_profile"
    for s3_bucket in "${most_likely_public[@]}"
    do
        bash_logging WARN "$s3_bucket is probably public please check"
    done

    for s3_bucket in "${error_buckets[@]}"
    do
        bash_logging WARN "$s3_bucket encountered error in query, please check status"
    done
done
