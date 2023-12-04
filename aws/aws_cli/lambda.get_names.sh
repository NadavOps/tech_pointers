#!/bin/bash

# Function to get Lambda function details for a specific region
get_lambda_details() {
    local region=$1
    local function_name=$2

    # Get the ARN of the execution role for the Lambda function
    execution_role_arn=$(aws lambda get-function-configuration --function-name "$function_name" --region "$region" --query 'Role' --output json)

    # Get details about the execution role
    execution_role_details=$(aws iam get-role --role-name "$(echo "$execution_role_arn" | jq -r 'split("/") | last')" --region "$region" --output json)

    # Extract and display relevant information
    role_last_used_date=$(echo "$execution_role_details" | jq -r '.Role.RoleLastUsed.LastUsedDate')
    role_arn=$(echo "$execution_role_details" | jq -r '.Role.Arn')

    echo "  Execution Role: $role_arn"
    echo "  Role Last Used Date: $role_last_used_date"
    echo "---"
}

# Get a list of all AWS regions or use a specific region if provided as an argument
if [ -z "$1" ]; then
    regions=$(aws ec2 describe-regions --query 'Regions[*].RegionName' --output json | jq -r '.[]')
else
    regions=("$1")
fi

# Iterate over each region
for region in $regions; do
    echo "Region: $region"

    # Get a list of all Lambda function names in the region
    function_names=$(aws lambda list-functions --region "$region" --query 'Functions[*].FunctionName' --output json)

    # Iterate over each function and get information about its execution role
    for function_name in $(echo "${function_names}" | jq -r '.[]'); do
        echo "Lambda Function: $function_name"
        get_lambda_details "$region" "$function_name"
    done
done
