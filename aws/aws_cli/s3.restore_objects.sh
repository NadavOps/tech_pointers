#!/bin/bash
## just testing here

s3_bucket=""
prefix="path/to/dir"
aws s3api list-object-versions --bucket "$s3_bucket" --prefix "$prefix" --query 'DeleteMarkers[?IsLatest==`true`]' | jq -r ".[].Key"


aws s3api list-object-versions --bucket mybucket --prefix myprefix/ --output json \
    --query 'DeleteMarkers[?LastModified>=`2020-07-07T00:00:00` && IsLatest==`true`].[Key,VersionId]' | jq -r '.[] |  "--key '\''" + .[0] +  "'\'' --version-id " + .[1]' |xargs -L1 echo aws s3api delete-object --bucket mybucket > files.txt

System defined Content-Type text/css
System defined Content-Type font/woff    (new is -> application/font-woff)