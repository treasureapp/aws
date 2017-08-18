go get -u github.com/mvdan/sh/cmd/shfmt
aws s3api create-bucket --cli-input-json file://create_s3_bucket.json
aws s3 sync . s3://treasureappbucket