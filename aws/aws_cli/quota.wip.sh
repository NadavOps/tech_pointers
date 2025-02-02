#!/bin/bash

quotas_struct=$(cat quota_codes.json)
quota_code=$(echo "$quotas_struct" | jq -r '.managed_policies_per_role_code.quota_code')
service_code=$(echo "$quotas_struct" | jq -r '.managed_policies_per_role_code.service_code')
default_value=$(echo "$quotas_struct" | jq -r '.managed_policies_per_role_code.default_value')
desired_value=$(echo "$quotas_struct" | jq -r '.managed_policies_per_role_code.desired_value')

current_value=$(aws service-quotas get-service-quota --service-code "$service_code" --quota-code "$quota_code" | jq -r '.Quota.Value')
if [[ "$current_value" == "$default_value" ]]; then
    echo "INFO: Value is currently the default $current_value, checking if a request was issued"
    requested_quota=$(aws service-quotas list-requested-service-quota-change-history --service-code "$service_code" | jq -r '.RequestedQuotas[] | select (.QuotaCode == "'$quota_code'")')
    if [[ -z "$requested_quota" ]]; then
        echo "INFO: requesting increase for $service_code $quota_code"
        aws service-quotas request-service-quota-increase --service-code "$service_code" --quota-code "$quota_code" --desired-value "$desired_value"
    else
        echo "INFO: inncrease request was already sent for $service_code $quota_code"
        echo "$requested_quota"
    fi
else
    echo "INFO: Value is currently NOT the default and will not be requested for change- $current_value"
fi


## need flags
# flag to make the request although the default was changed
## to iterate on different profiles
# region_of_choise="us-***"
# for profile in $(aws configure list-profiles | grep "pattern"); do
#     echo AWS_REGION="$region_of_choise" AWS_PROFILE="$profile" ./quota.wip.sh
#     AWS_REGION="$region_of_choise" AWS_PROFILE="$profile" ./quota.wip.sh
#     echo "===="
# done
