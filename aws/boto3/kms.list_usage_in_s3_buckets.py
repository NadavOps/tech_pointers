#!/usr/bin/env python3
import boto3

def get_bucket_encryption(bucket_name, region):
    """
    Get the encryption settings for a given S3 bucket.
    """
    s3 = boto3.client('s3', region_name=region)
    try:
        response = s3.get_bucket_encryption(Bucket=bucket_name)
        return response['ServerSideEncryptionConfiguration']['Rules']
    except s3.exceptions.ClientError as e:
        if e.response['Error']['Code'] == 'ServerSideEncryptionConfigurationNotFoundError':
            return None
        else:
            raise e

def get_bucket_kms_key(bucket_name, region):
    """
    Get the KMS key associated with a given S3 bucket.
    """
    s3 = boto3.client('s3', region_name=region)
    response = s3.get_bucket_encryption(Bucket=bucket_name)
    rules = response.get('ServerSideEncryptionConfiguration', {}).get('Rules', [])
    for rule in rules:
        if 'ApplyServerSideEncryptionByDefault' in rule:
            if 'KMSMasterKeyID' in rule['ApplyServerSideEncryptionByDefault']:
                return rule['ApplyServerSideEncryptionByDefault']['KMSMasterKeyID']
    return None

def main():
    s3 = boto3.client('s3')
    response = s3.list_buckets()

    for bucket in response['Buckets']:
        bucket_name = bucket['Name']
        bucket_region = boto3.client('s3').get_bucket_location(Bucket=bucket_name)["LocationConstraint"] or 'us-east-1'

        kms_key = get_bucket_kms_key(bucket_name, bucket_region)
        if kms_key:
            print(f"Bucket: {bucket_name}")

            encryption = get_bucket_encryption(bucket_name, bucket_region)
            if encryption:
                print("Encryption:")
                for rule in encryption:
                    print(f"- {rule['ApplyServerSideEncryptionByDefault']['SSEAlgorithm']}")
            print(f"KMS Key: {kms_key}")
            print()

if __name__ == "__main__":
    main()
