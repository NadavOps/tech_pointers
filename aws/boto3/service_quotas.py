#!/usr/bin/env python3

import argparse
import boto3
from botocore.exceptions import ClientError
import re
from iterfzf import iterfzf
from utilities_functions import get_regions, logging_configuration

def argument_parsing():
    parser = argparse.ArgumentParser()
    parser.add_argument('--aws_profile', type=str, help='AWS profile to use')
    parser.add_argument('--aws_regions', type=str, default="", help='AWS regions')
    parser.add_argument('--aws_exclude_regions', type=str, default="", help='AWS regions to exclude')
    parser.add_argument('--aws_service_code', type=str, default="", help='AWS service quota code')
    parser.add_argument('--aws_quota_code', type=str, default="", help='AWS service quota sub code')
    parser.add_argument('--aws_service_quota_value_request', type=str, default="", help='AWS service quota value request')
    arguments = parser.parse_args()
    return arguments

def get_service_quotas_codes(service_quotas_client, search_term: str = "") -> list[dict]:
    services = []
    paginator = service_quotas_client.get_paginator('list_services')

    for page in paginator.paginate():
        for service in page['Services']:
            services.append({
                'Code': service['ServiceCode'],
                'Name': service['ServiceName']
            })

    if search_term:
        regex = re.compile(re.escape(search_term), re.IGNORECASE)
        services = [s for s in services if regex.search(s['Code']) or regex.search(s['Name'])]

    return sorted(services, key=lambda x: x['Code'])

def get_service_quotas_sub_code(service_quotas_client, service_code: str, quota_code: str) -> dict:
    response = service_quotas_client.get_service_quota(
        ServiceCode=service_code,
        QuotaCode=quota_code
    )
    quota = response['Quota']
    return {
        'Name': quota['QuotaName'],
        'Value': quota['Value'],
        'Code': quota['QuotaCode']
    }

def get_service_quotas_sub_codes(service_quotas_client, service_code: str):
    quotas = []
    paginator = service_quotas_client.get_paginator('list_service_quotas')

    for page in paginator.paginate(ServiceCode=service_code):
        for quota in page['Quotas']:
            quotas.append({
                'Name': quota['QuotaName'],
                'Value': quota['Value'],
                'Code': quota['QuotaCode']
            })
    return quotas

def request_quota_increase(service_quotas_client, service_code: str, quota_code: str, desired_value: float):
    try:
        response = service_quotas_client.request_service_quota_increase(
            ServiceCode=service_code,
            QuotaCode=quota_code,
            DesiredValue=desired_value
        )

        request_info = response['RequestedQuota']
        print(f"✅ Success! Request submitted.")
        print(f"Request ID: {request_info['Id']}")
        print(f"Status:     {request_info['Status']}")

        return request_info

    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']

        if error_code == 'QuotaExceededException':
            print(f"❌ Error: You already have a pending request for this quota.")
        elif error_code == 'IllegalArgumentException':
            print(f"❌ Error: The desired value must be higher than the current quota.")
        else:
            print(f"❌ AWS Error [{error_code}]: {error_message}")

        return None


def main():
    arguments = argument_parsing()
    session = boto3.Session(profile_name=arguments.aws_profile)
    service_quotas_client = session.client('service-quotas')
    if arguments.aws_service_code:
        selected_service_quota_code = arguments.aws_service_code
    else:
        service_quotas_codes = get_service_quotas_codes(service_quotas_client)
        selected_service_quota_code = iterfzf([s['Code'] for s in service_quotas_codes])

    if arguments.aws_quota_code:
        selected_service_quota_sub_code = arguments.aws_quota_code
        selected_service_quota_sub = get_service_quotas_sub_code(service_quotas_client, selected_service_quota_code, selected_service_quota_sub_code)
    else:
        service_quotas_sub_codes = get_service_quotas_sub_codes(service_quotas_client, selected_service_quota_code)
        service_quota_sub_lookup = {s['Name']: s for s in service_quotas_sub_codes}
        selected_service_quota_sub_name = iterfzf(list(service_quota_sub_lookup.keys()))
        selected_service_quota_sub = service_quota_sub_lookup[selected_service_quota_sub_name]

    selected_service_quota_sub_name = selected_service_quota_sub['Name']
    selected_service_quota_sub_value = selected_service_quota_sub['Value']
    selected_service_quota_sub_code = selected_service_quota_sub['Code']

    print(f"Selected service quota sub name: {selected_service_quota_sub_name}")
    print(f"Selected service quota sub value: {selected_service_quota_sub_value}")
    print(f"Selected service quota sub code: {selected_service_quota_sub_code}")

    if not arguments.aws_service_quota_value_request:
        print("No service quota value request provided, exiting.")
        return

    ec2_client = session.client('ec2')
    regions = get_regions(ec2_client, selected_regions=arguments.aws_regions, exclude_regions=arguments.aws_exclude_regions)
    for region in regions:
        service_quotas_client = session.client('service-quotas', region_name=region)
        request_quota_increase(service_quotas_client, selected_service_quota_code, selected_service_quota_sub_code, float(arguments.aws_service_quota_value_request))


if __name__ == "__main__":
    main()