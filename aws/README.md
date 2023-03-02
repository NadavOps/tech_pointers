# AWS

# Table of Content
* [RDS](#rds)
* [Links](#links)

# RDS
## Storage scaling conditions
Amazon RDS starts a storage modification for an autoscaling-enabled DB instance when these factors apply:  
1. Free available space is less than 10 percent of the allocated storage.
2. The low-storage condition lasts at least five minutes.
3. At least six hours have passed since the last storage modification, or storage optimization has completed on the instance, whichever is longer.

# Links

* [EC2 Instances info](https://instances.vantage.sh/).
* Graviton links:
    * [docker buildx to support images on both](https://docs.docker.com/build/buildx/install/)
    * [EKS supported images](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html#arm-ami)
    * [Adjust kube-proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html#updating-kube-proxy-add-on)
* Opensearch
    * [Set SSO APP with AWS SSO](https://geeks.wego.com/integrate-aws-iam-identity-center-sso-saml-with-for-amazon-opensearch-dashboard/)
* Workshops:
    * [AWS well architected](https://www.wellarchitectedlabs.com/)
    * [Aurora workshop](https://awsauroralabsmy.com/provisioned/create/).
    * OpenSearch workshops
        * [Introduction to Amazon Elasticsearch](https://aws-dojo.com/ws43/labs/)
        * [Welcome to Amazon Elasticsearch Service Workshops](https://aesworkshops.com/)
        * [Microservice Observability with Amazon OpenSearch Service Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/1abb648b-2ef8-442c-a731-efbcb69c1e1e/en-US)
        * [SIEM on Amazon OpenSearch Service Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/60a6ee4e-e32d-42f5-bd9b-4a2f7c135a72/en-US)
* [AWS cli example with built in query](https://www.commandlinefu.com/commands/view/13122/use-aws-cli-and-jq-to-get-a-list-of-instances-sorted-by-launch-time)
