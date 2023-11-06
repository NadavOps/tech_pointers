# AWS

# Table of Content
* [EC2](#ec2)
* [RDS](#rds)
* [Amazon QuickSight](#amazon-quickSight)
* [Links](#links)

# EC2
## Files
/var/log/cloud-init-output.log
/var/lib/cloud/instance/scripts

# RDS
## Storage scaling conditions
Amazon RDS starts a storage modification for an autoscaling-enabled DB instance when these factors apply:  
1. Free available space is less than 10 percent of the allocated storage.
2. The low-storage condition lasts at least five minutes.
3. At least six hours have passed since the last storage modification, or storage optimization has completed on the instance, whichever is longer.

# Amazon QuickSight
## IAM SSO configuration
* Based on the [article](https://static.global.sso.amazonaws.com/app-b1262cec5a6d8194/instructions/index.htm).
1. Create a QuickSight application in IAM Identity Center with the defaults:
    * Relay state:               https://quicksight.aws.amazon.com
    * Application ACS URL:       https://signin.aws.amazon.com/saml
    * Application SAML audience: urn:amazon:webservices
    * Download the metadata
2. Define the application mappings: (Field, Value, Format)
    * Subject, ${user:email}, emailAddress
    * https://aws.amazon.com/SAML/Attributes/Role, arn:aws:iam::ACCOUNTID:role/ROLENAME,arn:aws:iam::ACCOUNTID:saml-provider/SAMLPROVIDERNAME, unspecified
    * https://aws.amazon.com/SAML/Attributes/RoleSessionName, ${user:email}, unspecified
    * https://aws.amazon.com/SAML/Attributes/PrincipalTag:Email, ${user:email}, uri (or unspecified)
3. Add allowed enteties to the application
4. Define identity provider: (for each permission)
    * upload the application metadata to it (each application will map to different permissions)
5. Create a role to work with the identity provider defined
    * Admin example:
    ```json
    // Trust relationship
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::ACCOUNTID:saml-provider/IDENTITY_PROVIDER_NAME"
                },
                "Action": "sts:AssumeRoleWithSAML",
                "Condition": {
                    "StringEquals": {
                        "SAML:aud": "https://signin.aws.amazon.com/saml"
                    }
                }
            },
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::ACCOUNTID:saml-provider/IDENTITY_PROVIDER_NAME"
                },
                "Action": "sts:TagSession",
                "Condition": {
                    "StringLike": {
                        "aws:RequestTag/Email": "*"
                    }
                }
            }
        ]
    }
    // Admin policy
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": "quicksight:CreateAdmin",
                "Resource": "arn:aws:quicksight:*:ACCOUNTID:user/${aws:userid}"
            }
        ]
    }
    // Reader policy
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": "quicksight:CreateReader",
                "Resource": "arn:aws:quicksight:*:ACCOUNTID:user/${aws:userid}"
            }
        ]
    }
    ```
6. Connect to Quicksight using the prime user (not via SSO) and configure SSO. person icon -> manage quicksight -> SSO
    * Email Syncing for Federated Users -> on
    * Service Provider Initiated SSO -> off
    * IdP URL -> get this one by right clicking the quicksight app listed now in the portal to copy its link and paste here
    * IdP redirect URL parameter -> RelayState
7. Not sure if this IAM role is created initially on Quicksight creation:
```json
    // Trust relationship
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "quicksight.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    // Policy
    Whatever policy u want to allow to the service, for example managed policy `AWSQuicksightAthenaAccess`
```

# Links

* [EC2 Instances info](https://instances.vantage.sh/).
* [AWS marketplace support page](https://aws.amazon.com/marketplace/management/contact-us)
* Graviton links:
    * [docker buildx to support images on both](https://docs.docker.com/build/buildx/install/)
    * [EKS supported images](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html#arm-ami)
    * [Adjust kube-proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html#updating-kube-proxy-add-on)
* Opensearch
    * [Set SSO APP with AWS SSO](https://geeks.wego.com/integrate-aws-iam-identity-center-sso-saml-with-for-amazon-opensearch-dashboard/)
* EKS
    * [https://www.stacksimplify.com/aws-eks/](https://www.stacksimplify.com/aws-eks/)
* Workshops:
    * [AWS well architected](https://www.wellarchitectedlabs.com/)
    * [Aurora workshop](https://awsauroralabsmy.com/provisioned/create/).
    * OpenSearch workshops
        * [Introduction to Amazon Elasticsearch](https://aws-dojo.com/ws43/labs/)
        * [Welcome to Amazon Elasticsearch Service Workshops](https://aesworkshops.com/)
        * [Microservice Observability with Amazon OpenSearch Service Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/1abb648b-2ef8-442c-a731-efbcb69c1e1e/en-US)
        * [SIEM on Amazon OpenSearch Service Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/60a6ee4e-e32d-42f5-bd9b-4a2f7c135a72/en-US)
* [AWS cli example with built in query](https://www.commandlinefu.com/commands/view/13122/use-aws-cli-and-jq-to-get-a-list-of-instances-sorted-by-launch-time)
* [Curl aws-sig4](https://curl.se/docs/manpage.html#--aws-sigv4)
