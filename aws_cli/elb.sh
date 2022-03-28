aws elb describe-load-balancers --query 'LoadBalancerDescriptions[].LoadBalancerName' | jq -r ".[]"

aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' | jq -r ".[]"
for elb_item in $(aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' | jq -r ".[]"); do
    echo "$elb_item"
    aws elbv2 describe-listeners --load-balancer-arn $elb_item
done

# Link: https://stackoverflow.com/questions/51584547/aws-cli-elb-elbv2-how-to-filter-load-balancers-by-dnsname
# Link: https://gist.github.com/tfentonz/96d39dc021b382c3d58eb2f96f4605df
