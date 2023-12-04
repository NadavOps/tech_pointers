import argparse
import boto3
import re

def extract_policy_names(file_content):
    # Define the regex pattern to match the name attribute within resource blocks
    pattern = re.compile(r'resource "aws_iam_policy" ".*?" {\s*[^#]*?name\s*=\s*"([^"]+)"')

    # Find all matches in the file content
    matches = pattern.findall(file_content)

    return matches

def check_policy_attachment(account_id, policy_name):
    # Construct the policy ARN without path (default)
    policy_arn_without_path = f"arn:aws:iam::{account_id}:policy/{policy_name}"

    # Construct the policy ARN with path (service role)
    policy_arn_with_path = f"arn:aws:iam::{account_id}:policy/service-role/{policy_name}"

    # Create an IAM client
    iam = boto3.client('iam')

    # Check if the policy itself exists (without path)
    if check_policy_exists(iam, policy_arn_without_path):
        # Check with policy ARN without path (default)
        check_policy_attachment_for_arn(iam, policy_arn_without_path)
        return

    # Check if the policy itself exists (with path)
    if check_policy_exists(iam, policy_arn_with_path):
        # Check with policy ARN with path (service role)
        check_policy_attachment_for_arn(iam, policy_arn_with_path)
        return

    # Policy does not exist for both options
    print(f"Policy with name '{policy_name}' does not exist.")

def check_policy_attachment_for_arn(iam, policy_arn):
    try:
        # Get a list of roles that are attached to the policy
        roles_response = iam.list_entities_for_policy(PolicyArn=policy_arn, EntityFilter='Role')

        # Check if there are roles attached to the policy
        if roles_response['PolicyRoles']:
            print(f"Policy {policy_arn} is attached to the following roles:")
            for role in roles_response['PolicyRoles']:
                print(f"- {role['RoleName']}")
            return True  # Policy found, no need to check the other option
    
    except iam.exceptions.NoSuchEntityException:
        # Policy not found for this option
        return False

def check_policy_exists(iam, policy_arn):
    try:
        # Attempt to get policy information
        iam.get_policy(PolicyArn=policy_arn)
        return True  # Policy exists
    except iam.exceptions.NoSuchEntityException:
        return False  # Policy does not exist

def main():
    parser = argparse.ArgumentParser(description='Check IAM policy attachments from a Terraform file')
    parser.add_argument('-f', '--file', dest='file_path', required=True, help='Path to the Terraform file')
    parser.add_argument('-a', '--account', dest='account_id', required=True, help='AWS Account ID')

    args = parser.parse_args()

    # Read the content of the Terraform file
    with open(args.file_path, 'r') as file:
        file_content = file.read()

    # Extract policy names
    policy_names = extract_policy_names(file_content)

    # Output the policy names
    for policy_name in policy_names:
        check_policy_attachment(args.account_id, policy_name)

if __name__ == "__main__":
    main()
