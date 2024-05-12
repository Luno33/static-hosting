# Static Hosting

This project demonstrate how to self-host multiple websites on a 5.99 euro/month VPS (https://webdock.io/en/pricing).

It uses:
- **Umami** (https://umami.is/) for an open-source, cookieless alternative to Google Analytics
- **Caddy** (https://caddyserver.com/) to handle caching and forwarding of traffic to Umami and the containerized website. It takes care automatically of the HTTPS certificates
- **Docker** (https://www.docker.com/) as a containerization system
- **Docker Compose** (https://docs.docker.com/compose/) to orchestrate the containers
- **Ansible** (https://www.ansible.com/) to set everything up on a shiny new empty VPS

... giving for granted that the rented VPS will be an Ubuntu or Debian machine.

Since Webdock gives by default Ubuntu machines, this repo is optimized for Ubuntu.

### Architecture

![architecture](./readme-assets/schemas/architecture.png)

## Getting started

To switch easily from one environment to the other we'll use to `.env` files:

`./secrets/.env.qa`:

```bash
export SITE_ADDRESS=localhost # For exposing the website on localhost
export UMAMI_HASH_SALT=************* # Random string useful for umami
export POSTGRES_USER=************* # New username for umami database
export POSTGRES_PASSWORD=************* # The password for that new user
```

`./secrets/.env.prod`:

```bash
export SITE_ADDRESS=example.com # The domain that you bought and want to configure
export UMAMI_HASH_SALT=************* # Random string useful for umami
export POSTGRES_USER=************* # New username for umami database
export POSTGRES_PASSWORD=************* # The password for that new user
export VPS_ADDRESS=***.***.***.*** # the address of your VPS
export REMOTE_WORKING_FOLDER=/path/to/your/vps/working/folder # the root working folder on your VPS
```

### Set up on your local machine

1. Install on your machine docker
  1. Follow the instructions here: https://docs.docker.com/get-docker/
2. Build your static website in a small Caddy container
    - **------------------------------------------------------ TODO ------------------------------------------------------**
3. Run it
    ```bash
    source ./secrets/.env.qa
    sudo -E docker-compose pull && sudo -E docker compose up
    ```
4. Navigate on https://localhost and https://tracking.localhost to test that everything works

### Set up on a remove server

1. Rent a VPS on your favorite VPS provider. Good examples: https://webdock.io/en, https://www.vultr.com/, https://www.linode.com/
2. Follow the readme in the [vps-setup folder](../vps-setup/README.md) to 
    1. install on the VPS all the needed dependencies
    2. push to the VPS all the file from this repository that are needed
3. Get a domain and point it on your VPS IP address
4. Build your static website in a small Caddy container and push it to a remote container registry
    - **------------------------------------------------------ TODO ------------------------------------------------------**
5. Run it
    ```bash
    source ./secrets/.env.prod
    sudo -E docker-compose pull && sudo -E docker compose up
    ```

## Usage

### Start the local (QA) environment

Locally

```bash
source ./secrets/.env.qa
sudo -E docker compose up
```

Remotely

```bash
source ./secrets/.env.prod
sudo -E docker compose up
```

### Deploy a new version of your website

Locally

```bash
docker build -t website . # In your website project folder
sudo -E docker compose up
```

Remotely

```bash
# docker login
# docker build remote tag
# docker push
# ssh into the machine
docker-compose pull && docker-compose up -d
```

### Download a folder for backup purposes

```bash
source ./secrets/.env.prod
rsync -chavzP --stats $VPS_ADDRESS:/remote/folder/path /local/folder/path
```

### Push on the server new configurations

```bash
source ./secrets/.env.prod
rsync -chavzP --stats \
  --include='caddy/Caddyfile' \
  --include='secrets/***' \
  --include='docker-compose.yml' \
  --exclude='*' \
  ./ $VPS_ADDRESS:$REMOTE_WORKING_FOLDER
```

## Notes

- [umami/README.md](umami/README.md)
- [Google Search Console Setup](./readme-assets/google-search-console.md)
