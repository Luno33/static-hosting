# Getting Started Remote Guide

## Step 1 - Names

We'll take for example in this guide that your websites are called `website1` and `website2` and the two production domains are called `website1prod.com` and `website2prod.com`.

You'll have to choose your domain (or domains) and use those instead of `website1prod.com` and `website2prod.com`.

## Step 2 - VPS Renting

You can rent a VPS on services like https://webdock.io/en, https://www.vultr.com/, https://www.linode.com/, etc...

## Step 3 - VPS Setup

Follow the linked guide [vps-setup folder](../vps-setup/README.md)

## Step 4 - Self Signed Certificates

We have to generate self-signed certificate for testing, and we'll use Let's Encrypt to generate proper certificates for production.

To generate self-signed certificates for local development execute this command command from the root folder of the project on the server:

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./self-signed/private/nginx-selfsigned.key -out ./self-signed/certs/nginx-selfsigned.crt
```

change it to be readable

```bash
sudo chmod +x ./self-signed/private/nginx-selfsigned.key
```

## Step 5 - Get a domain

If you did not buy a domain yet, you can buy it from https://www.namecheap.com/, https://www.godaddy.com/, https://domains.google/, etc...

When you have one, set up your CDN to point at your VPS IP address for the domain you've chosen, for this guide it would be `website1prod.com`, `website2prod.com`.

Umami will be just one instance that can serve all of your website. To work, it needs it's own subdomain on one of the domains you already own, so choose one of your domain that will be used for the `tracking` subdomain.

In this case I've chosen the `website1prod.com` domain to have the `tracking` subdomain, so point `tracking.website1prod.com` to your VPS IP address.

## Step 6 - Nginx configuration

On the server the file `nginx/conf/nginx.conf` is the default file that will get mounted and used by the nginx container and there is no need for modifications here.

On the server the configurations for your websites goes under `nginx/conf/custom-conf-prod`, where you'll find already there some real-world examples.

On the server the files `nginx/conf/custom-conf-prod/website1prod.com` and `nginx/conf/custom-conf-prod/website2prod.com` already represents two fully working configurations to expose `website1` and `website2`.

As you can see there, regarding the SSL certificates:

```bash
# self-signed certificates
ssl_certificate     /etc/ssl/certs/nginx-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

# letsencrypt certificates
# ssl_certificate     /etc/letsencrypt/live/certificates.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/certificates.com/privkey.pem; 
```

The letsencrypt certificates are commented out, and it's ok like this for now as they do not exist yet.

On the server, the file `nginx/conf/custom-conf/tracking.website1prod.com` already configure how to expose Umami on the `tracking` subdomain of the `website1prod.com` domain.

Exactly like it happened for `nginx/conf/custom-conf/website1prod.com` and `nginx/conf/custom-conf/website2prod.com`, the letsencrypt certificates are commented out for now.

## Step 7 - Run

From the root of the project on the server run the command

```bash
sudo docker compose --env-file ./secrets/.env.prod up
```

## Step 8 - Minio login and buckets creation

Go on http://**<YOUR_VPS_IP_ADDRESS>**:9001/ and you'll be redirect on the Minio admin panel.
Instead of YOUR_VPS_IP_ADDRESS you should put your VPS IP address.

The login credentials are the ones defined in the `./secrets/.env.prod` file in the environmental variables `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`.

Now that you've logged in, from the "Buckets" tab you'll be able to create a new bucket.

![bucket creation](./images/bucket-creation.png)

If you are using the default nginx configuration present in this repository in the files `nginx/conf/custom-conf/website1prod.com` and `nginx/conf/custom-conf/website2prod.com`, you'll have to create two buckets names `website1` and `website2` and you'll have to place in the root of those two buckets a folder named `out` and, inside that folder, files of your two websites.

## Step 9 - Minio policies

To enable unauthenticate accounts to view (but not delete, upload or modify) the files present in your buckets, for each bucket go to `Manage -> Summary -> Access Policy`. Make the access policy `custom` and paste the content of the file `minio/policies/minio-website1-access-policy.json` for website1 and `minio/policies/minio-website2-access-policy.json` for website2.

If your buckets are not called `website1` and `website2` remember to change the policies accordingly.

![bucket access policy](./images/bucket-access-policy.png)

## Step 10 - Uploads your website files

Use the UI to upload your files in the bucket `MINIO_BUCKET_PROD_NAME` or with the S3 CLI with:

```bash
aws --profile static-hosting-remote --endpoint-url http://$VPS_ADDRESS:$MINIO_VPS_PORT s3 cp ./out s3://$MINIO_BUCKET_PROD_NAME/ --recursive
```

## Step 11 - Get Certificates

You can generate (and renew) certificates with just one command line command.

Remember to substitute `your@email.com` with your actual email and `website1prod.com`/`website2prod.com`/`tracking.website1prod.com` with the domains that you want to request a certificate for.

```bash
export ACME_EMAIL=your@email.com # Your email address where Let's Encrypt will contact you
export ACME_DOMAINS='-d website1prod.com -d website2prod.com -d tracking.website1prod.com' # The domains to receive certificates on
docker compose -f docker-compose-certbot.yml up
```

## Step 12 - Use the new certificates

Remember in step 6 that the Let's Encrypt certificates usage was commented out and was active the usage of self-signed certificates?

Now it's time to swap those comment lines from the files `nginx/conf/custom-conf/website1prod.com`, `nginx/conf/custom-conf/website2prod.com`, and `nginx/conf/custom-conf/tracking.website1prod.com`:

The paths of the SSL certificates should not be changed as they are referenced in the Dockerfile.

```bash
# self-signed certificates
# ssl_certificate     /etc/ssl/certs/nginx-selfsigned.crt;
# ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

# letsencrypt certificates
ssl_certificate     /etc/letsencrypt/live/certificates.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/certificates.com/privkey.pem; 
```

## Step 13 - Check that it is working

Well Done! 

You should be able to hit https://website1prod.com and see your website in the website1 bucket. Likewise for website2!

Now you are also able to go to https://tracking.website1prod.com and configure Umami (and your website code) like the guide says: https://umami.is/docs/login.

## Step 14 - Certificates cronjob

If run on the server, this command will add a monthly execution of the certificate renewal.

Remember to do the variable substitutions as in Step 10 and to substitute `your@email.com` with your actual email and `website1prod.com`/`website2prod.com`/`tracking.website1prod.com` with the domains that you want to request a certificate for.

```bash
(crontab -l | grep . ; echo -e "0 0 1 * * ACME_EMAIL='--email your@email.com' ACME_DOMAINS='-d website1prod.com -d website2prod.com -d tracking.website1prod.com' docker compose -f docker-compose-certbot.yml up\n") | crontab -
```

If you want to check manually, run

```bash
crontab -e
```

To see if something went wrong with the previous renewals check the logs on the server in the folder `~/certbot/log/letsencrypt`.

## Step 15 - Check certificates

Check it by using the `docker-compose-certbot-check.yml` conf

```bash
docker compose -f docker-compose-certbot-check.yml up
```

It is useful to doublecheck that the certificate has been emitted correctly.
