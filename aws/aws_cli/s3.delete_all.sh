#!/bin/bash

delete_bucket_or_set_lifecycle_rules_for_deletion () {
    local bucket_name
    bucket_name="$1"
    bucket_response=$(aws s3api list-objects-v2 --bucket "$bucket_name" --max-items 1) || exit 1
    if [[ "$bucket_response" == "" ]]; then
        echo "Empty bucket, deleting"
        aws s3api delete-bucket --bucket "$bucket_name"
    else
        echo "NOT empty"
        # Create lifecyclerules according to https://repost.aws/knowledge-center/s3-empty-bucket-lifecycle-rule
        echo "Checking current lifecycle configuration"
        aws s3api get-bucket-lifecycle-configuration --bucket "$bucket_name" --no-cli-pager
        echo "Updating lifecycle configuration"
        aws s3api put-bucket-lifecycle-configuration \
        --bucket $bucket_name \
        --lifecycle-configuration '{
            "Rules": [
                {
                    "ID": "ExpireObjects",
                    "Filter": {},
                    "Status": "Enabled",
                    "Expiration": {
                        "Days": 1
                    },
                    "NoncurrentVersionExpiration": {
                        "NoncurrentDays": 1
                    },
                    "AbortIncompleteMultipartUpload": {
                        "DaysAfterInitiation": 1
                    }
                },
                {
                    "ID": "DeleteMarkers",
                    "Filter": {},
                    "Status": "Enabled",
                    "Expiration": {
                        "ExpiredObjectDeleteMarker": true
                    }
                }
            ]
        }'
        # aws s3 rm "s3://$bucket_name" --recursive
    fi
}

SPECIFIC_BUCKET="${1-}"
if [[ -z "$SPECIFIC_BUCKET" ]]; then
    echo "ERROR: provide param #3. either a pecific bucket to delete, or the parameter DELETE_ALL_BUCKETS_IN_ACCOUNT"
    exit 1
fi

echo "INFO: Running as:"
aws sts get-caller-identity
echo """INFO: Press enter to continue or ctrl+c to cancel.
      You can control the identity using AWS variables such as AWS_PROFILE, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY"
read

if [[ "$SPECIFIC_BUCKET" == "DELETE_ALL_BUCKETS_IN_ACCOUNT" ]]; then
    echo "INFO: Attempting deletion for all buckets in the account"
    for bucket_name in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
        echo "Processing bucket $bucket_name"

        delete_bucket_or_set_lifecycle_rules_for_deletion "$bucket_name"

        echo "======== Next Bucket ========="
    done
else
    echo "INFO: Attempting to delete bucket $SPECIFIC_BUCKET"
    delete_bucket_or_set_lifecycle_rules_for_deletion "$SPECIFIC_BUCKET"
fi
