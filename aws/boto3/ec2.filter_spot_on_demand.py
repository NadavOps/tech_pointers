import argparse
import boto3

def get_instance_info(ec2_client):
    instances = ec2_client.describe_instances()
    instance_info = []

    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            instance_type = instance['InstanceType']
            instance_state = instance['State']['Name']
            instance_lifecycle = instance.get('InstanceLifecycle', 'on-demand')
            instance_name = None

            for tag in instance.get('Tags', []):
                if tag['Key'].lower() == 'name':
                    instance_name = tag['Value']
                    break

            instance_info.append({
                'InstanceId': instance_id,
                'InstanceType': instance_type,
                'InstanceState': instance_state,
                'InstanceLifecycle': instance_lifecycle,
                'InstanceName': instance_name
            })

    return instance_info

def list_instances_for_region(region):
    ec2_client = boto3.client('ec2', region_name=region)
    instances = get_instance_info(ec2_client)

    spot_instances = []
    on_demand_instances = []

    for instance in instances:
        print(f"  Instance ID: {instance['InstanceId']}")
        print(f"    Type: {instance['InstanceType']}")
        print(f"    State: {instance['InstanceState']}")
        print(f"    Lifecycle: {instance['InstanceLifecycle']}")
        print(f"    Name: {instance['InstanceName']}")
        print()

        if instance['InstanceLifecycle'] == 'spot':
            spot_instances.append(instance)
        else:
            on_demand_instances.append(instance)

    return spot_instances, on_demand_instances

def list_instances_for_all_regions():
    ec2_regions = [region['RegionName'] for region in boto3.client('ec2').describe_regions()['Regions']]

    all_spot_instances = []
    all_on_demand_instances = []

    for region in ec2_regions:
        print(f"Region: {region}")
        ec2_client = boto3.client('ec2', region_name=region)
        spot_instances, on_demand_instances = list_instances_for_region(region)

        all_spot_instances.extend(spot_instances)
        all_on_demand_instances.extend(on_demand_instances)

    return all_spot_instances, all_on_demand_instances

def main():
    parser = argparse.ArgumentParser(description='List EC2 instances in a region.')
    parser.add_argument('--region', help='Specify a region to list instances in. If not provided, all regions will be considered.', default=None)
    args = parser.parse_args()

    if args.region:
        spot_list, on_demand_list = list_instances_for_region(args.region)
    else:
        spot_list, on_demand_list = list_instances_for_all_regions()

    print("Spot Instances:")
    for spot_instance in spot_list:
        print(f"  {spot_instance['InstanceId']} - {spot_instance['InstanceName']} - {spot_instance['InstanceType']}")

    print("\nOn-Demand Instances:")
    for on_demand_instance in on_demand_list:
        print(f"  {on_demand_instance['InstanceId']} - {on_demand_instance['InstanceName']} - {on_demand_instance['InstanceType']}")

if __name__ == "__main__":
    main()
