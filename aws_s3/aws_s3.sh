# set AWS keys
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_DEFAULT_REGION=

# set ENVS
BUCKET_NAME=
BUCKET_PATH=
if [[ -z $BUCKET_PATH ]]; then
    BUCKET_FULL_PATH=$BUCKET_NAME
else
    BUCKET_FULL_PATH=$BUCKET_NAME/$BUCKET_PATH
fi

# list bucket
aws s3 ls s3://$BUCKET_FULL_PATH

# copy object
aws s3 cp ./filename s3://$BUCKET_FULL_PATH/filename

# remove object
aws s3 rm s3://$BUCKET_FULL_PATH/filename

# get current bucket policy
aws s3api get-bucket-policy --bucket $BUCKET_NAME | jq .

# get bucket policy
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://policy_example.json 

# delete bucket policy
aws s3api delete-bucket-policy --bucket $BUCKET_NAME


#jms try
aws iam list-users --max-items 20 --query 'Users[?CreateDate<=`2021-12-16`] | [?UserName=~`user_name`]'


## Average file size in S3 folder
BUCKET_NAME=
BUCKET_FOLDER_PATH=
S3_TEXT_OUTPUT=$(aws s3 ls s3://$BUCKET_NAME/$BUCKET_FOLDER_PATH/ --recursive --human-readable  --summarize)
S3_TOTAL_OBJECTS=$(echo $S3_TEXT_OUTPUT | grep "Total Objects:" | cut -d ":" -f2 | tr -d " ")
S3_TOTAL_SIZE_NUMBER=$(echo $S3_TEXT_OUTPUT | grep "Total Size:" | cut -d ":" -f2 | cut -d " " -f2 | tr -d " ")
S3_TOTAL_SIZE_MESSUREMENT=$(echo $S3_TEXT_OUTPUT | grep "Total Size:" | cut -d ":" -f2 | cut -d " " -f3 | tr -d " ")
AVERAGE_OBJECT_SIZE=$(echo $((S3_TOTAL_SIZE_NUMBER / S3_TOTAL_OBJECTS)) $S3_TOTAL_SIZE_MESSUREMENT)