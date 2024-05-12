# Getting Started Local Guide

## Step 1 - Names

We'll take for example in this guide that your websites are called `website1` and `website2` and the two development domains are called `website1dev.com` and `website2dev.com`. We'll use the domains for reaching the websites and the names to create the buckets that contains their files.

## Step 2 - Install Docker

To install Docker follow the instructions here: https://docs.docker.com/get-docker/

## Step 3 - Self Signed Certificates

A Self-Signed certificate is needed to enable HTTPS locally, but browsers will try to block them as they are unsafe.

To generate self-signed certificates for local development execute this command from the root folder of the project:

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./self-signed/private/nginx-selfsigned.key -out ./self-signed/certs/nginx-selfsigned.crt
```

change it to be readable

```bash
sudo chmod +x ./self-signed/private/nginx-selfsigned.key
```

## Step 4 - `/etc/hosts`

Modify your `/etc/hosts` to put a redirect from your `WEBSITE_DEVELOPMENT_DOMAINS` to your localhost with a command like

```bash
sudo nano /etc/hosts
```

and add at the end the lines referring to your domains (in this guide two)

```bash
127.0.0.1 website1dev.com www.website1dev.com
127.0.0.1 website2dev.com www.website2dev.com
127.0.0.1 tracking.website1dev.com www.tracking.website1dev.com
```

Doing this, when you'll search on your browser website1dev.com or www.website1dev.com, it will be resolved by your local machine to 127.0.0.1, that is localhost.

Umami will be just one instance that can serve all of your website. To work, it needs it's own subdomain on one of the domains you already own, so choose one of your domain that will be used for the `tracking` subdomain.

In this case I've chosen the website1dev.com domain to handle the tracking subdomain.

## Step 5 - Nginx configuration

The file `nginx/conf/nginx.conf` is the default file that will get mounted and used by the nginx container and there is no need for modifications here.

The configurations for your local websites goes under `nginx/conf/custom-conf-qa`, where you'll find already there some real-world examples.

The files `nginx/conf/custom-conf-qa/website1dev.com` and `nginx/conf/custom-conf-qa/website2dev.com` already represents two fully working configurations to expose `website1` and `website2`. Please modify them to reflect your website names and domains.

The file `nginx/conf/custom-conf-qa/tracking.website1dev.com` already configure how to expose Umami on the `tracking` subdomain of the `website1dev.com` domain. Please modify it to reflect your website names and domains.

## Step 6 - Run

```bash
sudo docker compose --env-file ./secrets/.env.qa up
```

## Step 7 - Minio login and buckets creation

Minio is an S3-compatible self-hostable storage. It is where we will upload the files of our website.

Go on http://localhost:9001/ and you'll be redirect on the Minio admin panel.

The login credentials are the ones defined in the `./secrets/.env.qa` file in the environmental variables `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`.

Now that you've logged in, from the "Buckets" tab you'll be able to create a new bucket.

![bucket creation](./images/bucket-creation.png)

If you are using the default nginx configuration present in this repository in the files `nginx/conf/custom-conf-qa/website1dev.com` and `nginx/conf/custom-conf-qa/website2dev.com`, you'll have to create two buckets names `website1` and `website2` and you'll have to place in the root of those two buckets a folder named `out` and, inside that folder, files of your two websites.

Then store the full path in the `MINIO_BUCKET_QA_NAME` variable like this:

```bash
export MINIO_BUCKET_QA_NAME=website1/out
```

This environment variable it is used when files are uploaded using the S3 CLI, so you can change it to upload different websites.

## Step 8 - Minio policies

To let people see the website, we need to tell Minio that the "folder" where our files are should be publicly readable but not modifiable by everyone.

To enable unauthenticate accounts to view (but not delete, upload or modify) the files present in your buckets, for each bucket go to `Manage -> Summary -> Access Policy`. Make the access policy `custom` and paste the content of the file `minio/policies/minio-website1-access-policy.json` for website1 and `minio/policies/minio-website2-access-policy.json` for website2.

If your buckets are not called `website1` and `website2` remember to change the policies accordingly.

![bucket access policy](./images/bucket-access-policy.png)

## Step 9 - Uploads your website files

Use the UI to upload your files in the bucket `MINIO_BUCKET_QA_NAME` or with the S3 CLI.

To upload files with the AWS CLI you'll have first to install the AWS CLI on your machine and set a profile:

```bash
aws configure --profile static-hosting-remote
> AWS Access Key ID [None]: ************ # MINIO REMOTE ACCESS KEY
> AWS Secret Access Key [None]: ************************ # MINIO REMOTE SECRET KEY
> Default region name [None]: ENTER
> Default output format [None]: ENTER
```

Then to upload the local `./out` folder in the Minio's folder `website1/out` run:

```bash
export MINIO_BUCKET_QA_NAME=website1/out # the path of our bucket
aws --profile static-hosting-local --endpoint-url http://localhost:9000 s3 cp ./out s3://$MINIO_BUCKET_QA_NAME/ --recursive
```

To configure an AWS profile run `aws configure` and use the keys you can find in the Minio UI.

## Step 10

Well Done! 

You should be able to hit https://website1dev.com and see your website in the website1 bucket. Likewise for website2!

Now you are also able to go to https://tracking.website1dev.com and configure Umami (and your website code) like the guide says: https://umami.is/docs/login.
