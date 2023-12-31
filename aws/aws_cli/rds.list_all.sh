#!/bin/bash

# Get a list of all AWS regions
regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')

# Loop through each region
for region in $regions
do
    echo "Region: $region"

    rds_instances=$(aws rds describe-db-instances --region $region --query 'DBInstances[*].DBInstanceIdentifier' --output text)
    rds_clusters=$(aws rds describe-db-clusters --region $region --query 'DBClusters[*].DBClusterIdentifier' --output text)

    if [[ -z "$rds_instances" && -z "$rds_clusters" ]]; then
        echo "========================================"
        continue
    fi

    if [[ -n "$rds_instances" ]]; then
        echo "RDS Instances:"
        echo "$rds_instances"
    fi

    if [[ -n "$rds_clusters" ]]; then
        echo "RDS Clusters:"
        echo "$rds_clusters"
    fi

    echo "========================================"
done
