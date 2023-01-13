# Configure the AWS S3 API to talk to Minio

## Setup

- install the client: https://aws.amazon.com/cli/
- ```bash
  > aws configure
  AWS Access Key ID [None]: ************
  AWS Secret Access Key [None]: ************************
  Default region name [None]: ENTER
  Default output format [None]: ENTER
  ```
- aws configure set default.s3.signature_version s3v4

AWS Access Key ID and AWS Secret Access Key can be found on Minio on
`Access Keys` -> `Create access key` 

## List buckets

aws --endpoint-url http://127.0.0.1:9000 s3 ls

## List contents of buckets

aws --endpoint-url http://127.0.0.1:9000 s3 ls s3://personal-website/out/

## Make a bucket

aws --endpoint-url http://127.0.0.1:9000 s3 mb s3://mybucket

## Add an object to the bucket

aws --endpoint-url http://127.0.0.1:9000 s3 cp simplejson-3.3.0.tar.gz s3://mybucket

## Delete an object from a bucket

aws --endpoint-url http://127.0.0.1:9000 s3 rm s3://mybucket/argparse-1.2.1.tar.gz

## Remove a bucket

aws --endpoint-url http://127.0.0.1:9000 s3 rb s3://mybucket

## Upload a NextJS exported project

aws --endpoint-url http://127.0.0.1:9000 s3 cp ./out s3://personal-website/out/ --recursive

# Upload a file with REST API

- touch test.txt
- curl --upload-file ./test.txt http://127.0.0.1:9001/personal-website/
