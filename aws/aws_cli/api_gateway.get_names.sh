#!/bin/bash

# Get a list of all AWS regions
regions=$(aws ec2 describe-regions --output json | jq -r '.Regions[].RegionName')

# Iterate over each region
for region in $regions; do
  echo "Region: $region"
  
  # Use AWS CLI to list API Gateways in the current region
  api_gateway_names=$(aws apigateway get-rest-apis --region $region --output json | jq -r '.items[].name')

  # Print the API Gateway names in the current region
  echo "API Gateways:"
  for api_gateway_name in $api_gateway_names; do
    echo "- $api_gateway_name"
  done

  echo "-------------------------------------"
done
