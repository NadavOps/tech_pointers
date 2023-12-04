#!/bin/bash

# Get a list of CloudFront distributions
cloudfront_distributions=$(aws cloudfront list-distributions --query 'DistributionList.Items[*].Id' --output json)

# Iterate over each CloudFront distribution
for distribution_id in $(echo "${cloudfront_distributions}" | jq -r '.[]'); do
    echo "Distribution ID: ${distribution_id}"

    # Get Lambda@Edge associations for viewer-request and origin-request events
    viewer_request_function=$(aws cloudfront get-distribution-config --id "${distribution_id}" --query 'DistributionConfig.DefaultCacheBehavior.LambdaFunctionAssociations.Items[?EventType==`viewer-request`].LambdaFunctionARN' --output json)
    origin_request_function=$(aws cloudfront get-distribution-config --id "${distribution_id}" --query 'DistributionConfig.DefaultCacheBehavior.LambdaFunctionAssociations.Items[?EventType==`origin-request`].LambdaFunctionARN' --output json)

    # Print Lambda function details if associated
    if [ "${viewer_request_function}" != "null" ]; then
        echo "  Viewer Request Lambda Function: ${viewer_request_function}"
        # aws lambda get-function --function-name "$(echo "${viewer_request_function}" | jq -r '.[0]' | cut -d':' -f7)"
    fi

    if [ "${origin_request_function}" != "null" ]; then
        echo "  Origin Request Lambda Function: ${origin_request_function}"
        # aws lambda get-function --function-name "$(echo "${origin_request_function}" | jq -r '.[0]' | cut -d':' -f7)"
    fi

    echo "---"
done
