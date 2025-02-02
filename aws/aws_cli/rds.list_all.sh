#!/bin/bash

if [[ -n "$AWS_PROFILE" ]]; then 
    echo "INFO: AWS_PROFILE was supplied with the value $AWS_PROFILE"
fi

regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')

summary=""

for region in $regions
do
    echo "Region: $region"

    rds_instances=$(aws rds describe-db-instances --region $region --query 'DBInstances[*].DBInstanceIdentifier' --output text)
    rds_clusters=$(aws rds describe-db-clusters --region $region --query 'DBClusters[*].DBClusterIdentifier' --output text)

    num_instances=$(echo "$rds_instances" | wc -w)
    num_clusters=$(echo "$rds_clusters" | wc -w)

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

    summary+="$region: $num_instances instances, $num_clusters clusters"$'\n'
    echo "========================================"
done

echo "Summary:"
echo "$summary"
