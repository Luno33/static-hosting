# Getting Started Remote Guide

1. Decide your website names (referred as `WEBSITE_NAMES` in this guide) and your production domains (referred as `WEBSITE_PRODUCTION_DOMAINS`). Make sure that these domains are different from the ones you have chosen for development or you'll have to change your `/etc/hosts` everytime you'll switch between production and development.
2. Rent a VPS on your favorite VPS provider
3. Follow the readme in the [vps-setup folder](../vps-setup/README.md) to 
    1. install on the VPS all the needed dependencies
    2. push to the VPS all the file from this repository that are needed
4. SSH into the server and generate self-signed certificates
5. Point your domain on your VPS IP address
6. SSH into the server and customize the Nginx files to reflect your `WEBSITE_PRODUCTION_DOMAINS`, self-signed certificate files, and the Minio url that will point at your `WEBSITE_NAMES`
7. SSH into the server and spin up Nginx and Minio with docker compose locally
8. Go on the Minio portal and create a bucket for each `WEBSITE_NAMES`, called `WEBSITE_NAME`, containing your website files
9. Update Minio policy to give permission to everyone to see the files
10. Generate Let's Encrypt certificates
11. Modify the Nginx configuration to use the Let's Encrypt certificates
12. Navigate with the browser to one of your `WEBSITE_PRODUCTION_DOMAINS` domain and you should see your website
13. Set up a crontab to renew certificates
14. (optional) Check your certificates

## Step 1

We'll take for example in this guide that your websites are called `website1` and `website2` and the two development domains are called `website1prod.com` and `website2prod.com`.

You'll have to choose your domain (or domains) and use those instead of `website1prod.com` and `website2prod.com`.

## Step 2

You can rent a VPS on services like https://webdock.io/en, https://www.vultr.com/, https://www.linode.com/, etc...

## Step 3

Follow the linked guide [vps-setup folder](../vps-setup/README.md)

## Step 4

To generate self-signed certificates for local development execute this command command from the root folder of the project on the server:

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./self-signed/private/nginx-selfsigned.key -out ./self-signed/certs/nginx-selfsigned.crt
```

change it to be readable

```
sudo chmod +x ./self-signed/private/nginx-selfsigned.key
```

## Step 5

If you did not buy a domain yet, you can buy it from https://www.namecheap.com/, https://www.godaddy.com/, https://domains.google/, etc...

When you have one, set up your CDN to point at your VPS IP address.

## Step 6

On the server the file `nginx/conf/nginx.conf` is the default file that will get mounted and used by the nginx container and there is no need for modifications here.

On the server the configurations for your websites goes under `nginx/conf/custom-conf`, where you'll find already there some real-world examples.

On the server the files `nginx/conf/custom-conf/website1prod.com` and `nginx/conf/custom-conf/website2prod.com` already represents two fully working configurations to expose `website1` and `website2`.

As you can see there, regarding the SSL certificates:

```
# self-signed certificates
ssl_certificate     /etc/ssl/certs/nginx-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

# letsencrypt certificates
# ssl_certificate     /etc/letsencrypt/live/certificates.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/certificates.com/privkey.pem; 
```

The letsencrypt certificates are commented out, and it's ok like this for now.

## Step 7

From the root of the project on the server run the command

```
docker compose up
```

## Step 8

Go on http://YOUR_VPS_IP_ADDRESS:9001/ and you'll be redirect on the Minio admin panel.
Instead of YOUR_VPS_IP_ADDRESS you should put your VPS IP address.

The login credentials are the ones defined in the `./docker-compose.yml` in the environmental variables `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`. I strongly suggest you to change them with something secure.

Now that you've logged in, from the "Buckets" tab you'll be able to create a new bucket.

![bucket creation](./images/bucket-creation.png)

If you are using the default nginx configuration present in this repository in the files `nginx/conf/custom-conf/website1prod.com` and `nginx/conf/custom-conf/website2prod.com`, you'll have to create two buckets names `website1` and `website2` and you'll have to place in the root of those two buckets the index files of your two websites.

## Step 9

To enable unauthenticate accounts to view (but not delete, upload or modify) the files present in your buckets, for each bucket go to `Manage -> Summary -> Access Policy`. Make the access policy `custom` and paste the content of the file `minio/policies/minio-website1-access-policy.json` for website1 and `minio/policies/minio-website2-access-policy.json` for website2.

If your buckets are not called `website1` and `website2` remember to change the policies accordingly.

![bucket access policy](./images/bucket-access-policy.png)

## Step 10

You can generate (and renew) certificates with just one command line command.

Remember to substitute `your@email.com` with your actual email and `website1prod.com`/`website2prod.com` with the domains that you want to request a certificate for.

```
ACME_EMAIL='--email your@email.com' ACME_DOMAINS='-d website1prod.com -d website2prod.com' docker compose -f docker-compose-certbot.yml up
```

## Step 11

Remember in step 6 that the Let's Encript certificates usage was commented out and was active the usage of self-signed certificates?

Now it's time to swap those comment lines:

```
# self-signed certificates
# ssl_certificate     /etc/ssl/certs/nginx-selfsigned.crt;
# ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

# letsencrypt certificates
ssl_certificate     /etc/letsencrypt/live/certificates.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/certificates.com/privkey.pem; 
```

## Step 12

Well Done! 

You should be able to hit https://website1prod.com and see your website in the website1 bucket. Likewise for website2!

## Step 13

If run on the server, this command will add a monthly execution of the certificate renewal.

Remember to do the variable substitutions as in Step 10.

```
(crontab -l | grep . ; echo -e "0 0 1 * * ACME_EMAIL='--email test@test.com' ACME_DOMAINS='-d DOMAIN1.com -d DOMAIN2.com' docker compose -f docker-compose-certbot.yml up\n") | crontab -
```

If you want to check manually, run

```
crontab -e
```

To see if something went wrong with the previous renewals check the logs on the server in the folder `~/certbot/log/letsencrypt`.

## Step 14

Check it by using the docker-compose-certbot-check.yml conf

```
docker compose -f docker-compose-certbot-check.yml up
```
