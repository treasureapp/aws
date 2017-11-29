#! /bin/sh

echo "hello"

BUCKET_NAME=treasure-app
REGION=us-west-2
ACCOUNT_NUMBER=584221209899

#
# 1_static_website
#

# STEP 2:
# create new bucket
aws s3api create-bucket --create-bucket-configuration LocationConstraint=$REGION --cli-input-json file://1_static_website/create_s3_bucket.json
# STEP 3:
# set static public access policy
aws s3api put-bucket-policy --bucket $BUCKET_NAME"-bucket" --policy file://1_static_website/s3_public_access_policy.json
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
POOL_ID="us-west-2_yQDEFbVeC"
# STEP 2:
# add a client to the user pool
aws cognito-idp create-user-pool-client --user-pool-id $POOL_ID --client-name $BUCKET_NAME"-cognito-client" --no-generate-secret
# save client id
CLIENT_ID="4cfhb8467jl6lc2kknrb0jumfn"
# update (local) config.js with above ids
subl treasure-app"-bucket"/WebApplication/1_StaticWebHosting/website/js/config.js
# upload updated config.js (s3)
aws s3 sync $BUCKET_NAME"-bucket"/WebApplication/1_StaticWebHosting/website s3://$BUCKET_NAME"-bucket" --region $REGION

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
# STEP 1:
# create table
aws dynamodb create-table --table-name "Rides" --attribute-definitions AttributeName="RideId",AttributeType="S" --key-schema AttributeName="RideId",KeyType="HASH" --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=10
# save arn (amazon resource number)
# arn:aws:dynamodb:region:account-id:table/table-name
TABLE_ARN="arn:aws:dynamodb:us-west-2:584221209899:table/Rides"
# STEP 2:
# create iam role 
aws iam create-role --role-name "WildRydesLambda" --assume-role-policy-document file://role_policy.json
# save arn
ROLE_ARN=arn:aws:iam::584221209899:role/WildRydesLambda
ROLE_ID=AROAINII7J3ZCACT65LEI
# STEP 3:
# attach managed policies to role
aws iam attach-role-policy  --role-name "WildRydesLambda" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam attach-role-policy  --role-name "WildRydesLambda" --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess
# STEP 4:
# create lambda function
aws lambda create-function --function-name "RequestUnicorn" --code file://serverless_web_app/$BUCKET_NAME"-bucket"/WebApplication/3_ServerlessBackend/requestUnicorn.js --role "WildRydesLambda" --runtime "nodejs6.10" --handler index.handler 
# get s3 bucket
BUCKET=$(aws s3api list-buckets | awk ' { print $3 } ')

# http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/api-permissions-reference.html
# https://gist.github.com/gene1wood/55b358748be3c314f956

dynamodb:PutItem
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess --role-name ReadOnlyRole
a


#
# API Gateway 
#

