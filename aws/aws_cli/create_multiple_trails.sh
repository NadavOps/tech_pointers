#!/bin/bash
include_profile_pattern="admin"
desired_trail_name="trail_name_1"
trail_names=( "$desired_trail_name" "trail_name2" )
s3_to_log_trails="bucket_name"
for selected_aws_profile in $(aws configure list-profiles | grep "$include_profile_pattern"); do
    trail_exist="false"
    for trail_name in ${trail_names[@]}; do
        aws cloudtrail get-trail --profile "$selected_aws_profile" --name "$trail_name" 2> /dev/null \
            && bash_logging DEBUG "The trail \"$trail_name\" exist in \"$selected_aws_profile\"" && trail_exist="true" && break
    done
    if [[ "$trail_exist" == "false" ]]; then
        bash_logging WARN "trails don't exist in \"$selected_aws_profile\""
        aws cloudtrail create-trail --profile "$selected_aws_profile" --name "$desired_trail_name" --s3-bucket-name "$s3_to_log_trails" \
            --include-global-service-events \
            --is-multi-region-trail \
            --enable-log-file-validation
        aws cloudtrail start-logging --profile "$selected_aws_profile" --name "$desired_trail_name"
    fi
done
