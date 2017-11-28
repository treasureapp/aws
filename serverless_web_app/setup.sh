#! /bin/sh

echo "hello"

BUCKET_NAME=treasure-app-gc1234
REGION=us-west-1

# STEP 2:
# create new bucket
aws s3api create-bucket --cli-input-json file://create_s3_bucket.json
# STEP 3:
# set static public access policy
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://s3_public_access_policy.json
# STEP 4:
# upload website code from amazon's s3 bucket to my bucket
aws s3 sync s3://wildrydes-us-east-1/WebApplication/1_StaticWebHosting/website s3://$BUCKET_NAME --region $REGION
# STEP 5:
# enable static website hosting from bucket
aws s3 website s3://$BUCKET_NAME --index-document index.html

# TEST
open http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com
