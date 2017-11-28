#! /bin/sh

echo "hello"

BUCKET_NAME=treasure-app
REGION=us-west-2

#
# S3 static website
#

# STEP 2:
# create new bucket
aws s3api create-bucket --cli-input-json file://create_s3_bucket.json
# STEP 3:
# set static public access policy
aws s3api put-bucket-policy --bucket $BUCKET_NAME"-bucket" --policy file://s3_public_access_policy.json
# STEP 4:
# clone git repo
git clone https://github.com/awslabs/aws-serverless-workshops $BUCKET_NAME"-bucket"
# upload website code from amazon's s3 bucket to my bucket
aws s3 sync $BUCKET_NAME"-bucket"/WebApplication/1_StaticWebHosting/website s3://$BUCKET_NAME"-bucket" --region $REGION
# STEP 5:
# enable static website hosting from bucket
aws s3 website s3://$BUCKET_NAME"-bucket" --index-document index.html

# TEST:
open http://$BUCKET_NAME"-bucket".s3-website-$REGION.amazonaws.com


#
# Cognito user management
#

# STEP 1:
# Create Cognito user pool
aws cognito-idp create-user-pool --pool-name $BUCKET_NAME"-cognito-pool"
# save pool id
POOL_ID=us-west-2_NmXwnPKQw
# STEP 2:
# add a client to the user pool
aws cognito-idp create-user-pool-client --user-pool-id $POOL_ID --client-name $BUCKET_NAME"-cognito-client" --no-generate-secret
# save client id
CLIENT_ID=17n69utji52lmqesstrfo3ml5a
# update (local) config.js with above ids
subl treasure-app"-bucket"/WebApplication/1_StaticWebHosting/website/js/config.js
# upload updated config.js (s3)
aws s3 sync treasure-app-bucket/WebApplication/1_StaticWebHosting/website s3://$BUCKET_NAME"-bucket" --region $REGION

# TEST:
# register to mock website
open http://$BUCKET_NAME"-bucket".s3-website-$REGION.amazonaws.com/register.html
# manually confirm user
open https://us-west-2.console.aws.amazon.com/cognito/users/?region=us-west-2#/pool/$POOL_ID/users
# verify user is registered
open http://$BUCKET_NAME"-bucket".s3-website-$REGION.amazonaws.com/register.html


#
# Lambda on top of DynamoDB backend
#
# https://aws.amazon.com/getting-started/serverless-web-app/module-3/


#
# API Gateway 
#

