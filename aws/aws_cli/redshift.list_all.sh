#!/bin/bash

if [[ -n "$AWS_PROFILE" ]]; then 
    echo "INFO: AWS_PROFILE was supplied with the value $AWS_PROFILE"
fi

summary=""
total_clusters=0

regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')

for region in $regions
do
    echo "Region: $region"

    redshift_clusters=$(aws redshift describe-clusters --region $region --query 'Clusters[*].ClusterIdentifier' --output text)

    if [[ -n "$redshift_clusters" ]]; then
        cluster_count=$(echo "$redshift_clusters" | wc -w)
        total_clusters=$((total_clusters + cluster_count))
        summary="$summary\n- $region: $cluster_count clusters"
        echo "Redshift Clusters:"
        echo "$redshift_clusters"
    fi

    echo "========================================"
done

echo "Summary:"
if [[ $total_clusters -gt 0 ]]; then
    echo "Total Redshift Clusters Found: $total_clusters"
    echo -e "Breakdown by Region:$summary"
else
    echo "No Redshift Clusters Found in any region."
fi
