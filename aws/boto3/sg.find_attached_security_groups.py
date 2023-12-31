import argparse
import boto3

def list_network_interfaces(vpc_id=None, exclude_security_groups=[]):
    ec2 = boto3.client('ec2')

    # Describe all network interfaces, optionally filtering by VPC ID
    filters = [{'Name': 'vpc-id', 'Values': [vpc_id]}] if vpc_id else []
    response = ec2.describe_network_interfaces(Filters=filters)

    # Extract and print information about each network interface
    for network_interface in response['NetworkInterfaces']:
        interface_id = network_interface['NetworkInterfaceId']
        description = network_interface.get('Description', 'N/A')
        security_groups = network_interface['Groups']

        print(f"Network Interface ID: {interface_id}")
        print(f"Description: {description}")
        print("Associated Security Groups:")
        for sg in security_groups:
            if sg['GroupId'] not in exclude_security_groups:
                print(f"  - {sg['GroupId']} ({sg['GroupName']})")
        print("\n")

def list_unused_security_groups(vpc_id=None):
    ec2 = boto3.client('ec2')

    # Describe all security groups, optionally filtering by VPC ID
    filters = [{'Name': 'vpc-id', 'Values': [vpc_id]}] if vpc_id else []
    response = ec2.describe_security_groups(Filters=filters)

    # Create a mapping of security group IDs to their names
    security_group_name_map = {sg['GroupId']: sg['GroupName'] for sg in response['SecurityGroups']}

    # Get a set of all security group IDs
    all_security_groups = set(security_group_name_map.keys())

    # Get a set of security group IDs associated with network interfaces
    used_security_groups = set()
    network_interfaces_response = ec2.describe_network_interfaces(Filters=filters)
    for network_interface in network_interfaces_response['NetworkInterfaces']:
        security_groups = network_interface['Groups']
        used_security_groups.update(sg['GroupId'] for sg in security_groups)

    # Calculate the set difference to find unused security groups
    unused_security_groups = all_security_groups - used_security_groups

    print("Unused Security Groups:")
    for sg_id in unused_security_groups:
        sg_name = security_group_name_map.get(sg_id, "Unknown")
        print(f"  - {sg_id} ({sg_name})")

    return unused_security_groups, security_group_name_map

def delete_unused_security_groups(unused_security_groups, security_group_name_map):
    ec2 = boto3.client('ec2')

    # Delete unused security groups (excluding those named "default")
    for sg_id in unused_security_groups:
        sg_name = security_group_name_map.get(sg_id, "Unknown")
        if sg_name.lower() == 'default':
            print(f"Skipping deletion of security group '{sg_id}' with name 'default'.")
            continue

        try:
            ec2.delete_security_group(GroupId=sg_id)
            print(f"Deleted unused security group: {sg_name} - {sg_id}")
        except Exception as e:
            print(f"Error deleting security group {sg_name} - {sg_id}: {e}")

def parse_arguments():
    parser = argparse.ArgumentParser(description="AWS EC2 Network Interface and Security Group Information")
    parser.add_argument('--vpc', help="Optional VPC ID to filter the results")
    parser.add_argument('--delete_unused', action='store_true', help="Delete unused security groups")
    parser.add_argument('--exclude_security_groups', help="Security groups to exclude from the list")

    arguments = parser.parse_args()

    if arguments.exclude_security_groups:
        arguments.exclude_security_groups = [ s.strip() for s in arguments.exclude_security_groups.split(",") ]
    else:
        arguments.exclude_security_groups = []

    return arguments

if __name__ == "__main__":
    arguments = parse_arguments()

    print("Listing Network Interfaces:")
    list_network_interfaces(arguments.vpc, arguments.exclude_security_groups)

    print("Listing Unused Security Groups:")
    unused_security_groups, security_group_name_map = list_unused_security_groups(arguments.vpc)

    if arguments.delete_unused and unused_security_groups:
        confirm = input("Do you want to delete the unused security groups? (yes/no): ").lower()
        if confirm == "yes":
            delete_unused_security_groups(unused_security_groups, security_group_name_map)
        else:
            print("Unused security groups will not be deleted.")
