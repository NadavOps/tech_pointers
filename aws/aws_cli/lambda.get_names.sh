#!/bin/bash
regions=$(aws ec2 describe-regions --query 'Regions[*].RegionName' --output json | jq -r '.[]')

for region in $regions; do
    echo "Lambda functions in $region:"
    lambda_names=$(aws lambda list-functions --region $region --query 'Functions[*].FunctionName' --output json | jq -r '.[]')
    for lambda_name in $lambda_names; do
        echo "  - $lambda_name"
    done

    echo
done
