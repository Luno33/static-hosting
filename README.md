# Static Hosting

This project demonstrate how to self-host multiple websites on a 5.99 euro/month VPS (https://webdock.io/en/pricing).

It uses:
- **Minio** (https://min.io/) to have a self-hosted alternative to AWS S3. Since it uses the same api as AWS S3, it is compatible with AWS CLI, more info [here](minio/notes.md)
- **Umami** (https://umami.is/) for an open-source, cookieless alternative to Google Analytics
- **Nginx** (https://www.nginx.com/) to handle caching and forwarding of traffic to Minio
- **Let's encrypt** (https://letsencrypt.org/) to handle SSL certificates
- **Docker** (https://www.docker.com/) as a containerization system
- **Docker Compose** (https://docs.docker.com/compose/) to orchestrate the containers
- **Ansible** (https://www.ansible.com/) to set everything up on a shiny new empty VPS

... giving for granted that the rented VPS will be an Ubuntu or Debian machine.

Since Webdock gives by default Ubuntu machines, this repo is optimized for Ubuntu.

### How it works high level in a production environment

![production schema](./readme-assets/schemas/production.png)

### How it works high level in a development environment

![development schema](./readme-assets/schemas/development.png)

## Getting started

To switch easily from one environment to the other we'll use to `.env` files. Some fields can be filled only after the setup of the project (like the `MINIO_BUCKET_QA_NAME`, which requires first to configure Minio). Feel free to leave the empty and to fill them when the project will be fully set up.

`./secrets/.env.qa`:

```bash
export UMAMI_HASH_SALT=************* # Random string useful for umami
export POSTGRES_USER=************* # New username for umami database
export POSTGRES_PASSWORD=************* # The password for that new user
export MINIO_ROOT_USER==************* # Username for minio root user
export MINIO_ROOT_PASSWORD==************* # Password for minio root user
export NGINX_CONF_PATH=./nginx/conf/custom-conf-qa
export MINIO_BUCKET_QA_NAME=website1/out # The bucket path created in Minio for a specific website
```

`./secrets/.env.prod`:

```bash
export UMAMI_HASH_SALT=************* # Random string useful for umami
export POSTGRES_USER=************* # New username for umami database
export POSTGRES_PASSWORD=************* # The password for that new user
export MINIO_ROOT_USER==************* # Username for minio root user
export MINIO_ROOT_PASSWORD==************* # Password for minio root user
export NGINX_CONF_PATH=./nginx/conf/custom-conf-prod
export MINIO_BUCKET_PROD_NAME=website1/out # The bucket path created in Minio for a specific website
```

### Set up on your local machine

1. Decide your website names (referred as `WEBSITE_NAMES` in this guide), your development domains (referred as `WEBSITE_DEVELOPMENT_DOMAINS`)
2. Install on your machine docker
3. Generate self-signed certificates for local development
4. Modify your `/etc/hosts` to put a redirect from your `WEBSITE_DEVELOPMENT_DOMAINS` to your localhost
5. Customize the Nginx files to reflect your `WEBSITE_DEVELOPMENT_DOMAINS`, self-signed certificate files, the Minio url that will point at your `WEBSITE_NAMES` and the Umami nginx configuration
6. Spin up Nginx and Minio with docker compose locally
7. Go on the Minio portal and create a bucket for each `WEBSITE_NAMES`, called `WEBSITE_NAME`, containing your website files, put that folder in the environment variable `MINIO_BUCKET_QA_NAME`
8. Update Minio policy to give permission to everyone to see the files
9. Upload website files to the bucket
10. Navigate with the browser to one of your `WEBSITE_DEVELOPMENT_DOMAINS` domain and you should see your website

For more detailed information look at [readme-assets/getting-started-local-guide.md](readme-assets/getting-started-local-guide.md)

### Set up on a remove server

Put in the environment variable of the terminal the following

```bash
export VPS_ADDRESS=***.***.***.*** # The IP Address of the VPS of your choice
export MINIO_VPS_PORT=***** # The port where Minio (the S3 compatible storage) will use to receive the website files
export ACME_EMAIL=********@********.**** # Your email address where you want to receive the emails from Let's Encrypt
export ACME_DOMAINS='-d ********.**** -d ********.**** -d ********.****' # The domains you want to register to Let's Encrypt
```

1. Decide your website names (referred as `WEBSITE_NAMES` in this guide) and your production domains (referred as `WEBSITE_PRODUCTION_DOMAINS`). Make sure that these domains are different from the ones you have chosen for development or you'll have to change your `/etc/hosts` everytime you'll switch between production and development.
2. Rent a VPS on your favorite VPS provider
3. Follow the readme in the [vps-setup folder](../vps-setup/README.md) to 
    1. install on the VPS all the needed dependencies
    2. push to the VPS all the file from this repository that are needed
4. SSH into the server and generate self-signed certificates
5. Point your domain on your VPS IP address
6. SSH into the server and customize the Nginx files to reflect your `WEBSITE_PRODUCTION_DOMAINS`, self-signed certificate files, the Minio url that will point at your `WEBSITE_NAMES` and the Umami nginx configuration
7. SSH into the server and spin up Nginx and Minio with docker compose locally
8. Go on the Minio portal and create a bucket for each `WEBSITE_NAMES`, called `WEBSITE_NAME`, containing your website files
9. Update Minio policy to give permission to everyone to see the files
10. Upload website files to the buckets
11. Generate Let's Encrypt certificates
12. Modify the Nginx configuration to use the Let's Encrypt certificates
13. Navigate with the browser to one of your `WEBSITE_PRODUCTION_DOMAINS` domain and you should see your website
14. Set up a crontab to renew certificates
15. (optional) Check your certificates

For more detailed information look at [readme-assets/getting-started-remote-guide.md](readme-assets/getting-started-remote-guide.md)

## Usage

### Start the local (QA) environment

Locally

```bash
sudo docker compose --env-file ./secrets/.env.qa up
```

Remotely

```bash
sudo docker compose --env-file ./secrets/.env.prod up
```

### Deploy a new version of your website

Locally

```bash
aws --profile static-hosting-local --endpoint-url http://localhost:9000 s3 cp ./out s3://$MINIO_BUCKET_QA_NAME/ --recursive
```

Remotely

```bash
aws --profile static-hosting-remote --endpoint-url http://$VPS_ADDRESS:$MINIO_VPS_PORT s3 cp ./out s3://$MINIO_BUCKET_PROD_NAME/ --recursive
```

### Download a folder

```bash
export VPS_ADDRESS=***.***.***.*** # the address of your VPS
rsync -chavzP --stats $VPS_ADDRESS:/remote/folder/path /local/folder/path
```

### Push on the server new configurations

```bash
export VPS_ADDRESS=***.***.***.*** # the address of your VPS
export REMOTE_WORKING_FOLDER=/path/to/your/vps/working/folder 
rsync -chavzP --stats \
  --include='nginx/***' \
  --include='secrets/***' \
  --include='docker-compose-certbot-check.yml' \
  --include='docker-compose-certbot.yml' \
  --include='docker-compose.yml' \
  --exclude='*' \
  ./ $VPS_ADDRESS:$REMOTE_WORKING_FOLDER
```

### Reload Nginx to accept new certificates

```
docker compose exec nginx nginx -s reload
```

## Certificates Management

### Check Certificates

```bash
docker compose -f docker-compose-certbot-check.yml up
```

### Read Certificates Logs

```bash
cd ./certbot/log/letsencrypt
ls -tla --full-time # list sorted by date with full-time
```

### Renew Certificates

```bash
export ACME_EMAIL='--email ********@********.****'
export ACME_DOMAINS='-d ********.**** -d ********.**** -d ********.****'
docker compose -f docker-compose-certbot.yml up
docker compose exec nginx nginx -s reload
```

## Some notes regarding Umami

[umami/README.md](umami/README.md)

## To handle your domain

[Google Search Console Setup](./readme-assets/google-search-console.md)
