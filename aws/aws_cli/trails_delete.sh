#!/bin/zsh
include_profile_pattern="admin"
desired_trail_name="trail"
trail_names=( "$desired_trail_name" "Trail" )
for selected_aws_profile in $(aws configure list-profiles | grep "$include_profile_pattern"); do
    trail_exist="false"
    for trail_name in ${trail_names[@]}; do
        echo "Looking for \"$trail_name\" in \"$selected_aws_profile\"" \
        && aws cloudtrail get-trail --name "$trail_name" --profile "$selected_aws_profile" 2> /dev/null \
        && echo DEBUG "The trail \"$trail_name\" exist in \"$selected_aws_profile\"" \
        && trail_exist="true" \
        && aws cloudtrail delete-trail --name "$trail_name" --profile "$selected_aws_profile" \
        && break
    done
    if [[ "$trail_exist" == "false" ]]; then
        echo WARN "trails don't exist in \"$selected_aws_profile\""
    fi
done
