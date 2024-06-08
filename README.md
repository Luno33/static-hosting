# Static Hosting

This project demonstrate how to self-host a NextJS website on a 5.99 euro/month VPS (https://webdock.io/en/pricing). It can easily be extended to support other frameworks as the static files of NextJS are wrapped in a Caddy webserver.

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

## Prerequisites

This project needs an external Container Registry. Here are the GitLab instructrions as they have a generous free container registry, but you can use the one you prefer.
- Create a repository on GitLab for the website you want to host
- You'll get a Container Registry for that repository in the form of registry.gitlab.com/`YOUR_USERNAME`/`YOUR_REPOSITORY_NAME`. Example: `registry.gitlab.com/username1/website1`
- You'll store this url in the variable `CONTAINER_REGISTRY` of the next chapter below

## Getting started

The following guide is optimized for static websites built on NextJS. It is very easy to adapt it to other framework as the `./out` folder with the static files of NextJS is wrapped by a Caddy webserver. Potentially every static website can be wrapped in the same way.

To switch easily from one environment to the other we'll use to `.env` files:

`./secrets/.env.qa`:

```bash
export DOMAIN=localhost # For exposing the website on localhost
export UMAMI_HASH_SALT=************* # Random string useful for umami
export POSTGRES_USER=************* # New username for umami database
export POSTGRES_PASSWORD=************* # The password for that new user
export WEBSITE_CONTAINER_REGISTRY=************* # The container registry url as explained in the previous chapter
export WEBSITE_CONTAINER_URI=container-name:container-version # example: john/website:latest
export WEBSITE_PROJECT_PATH=/full/path/to/your/website/project/root
```

`./secrets/.env.prod`:

```bash
export DOMAIN=example.com # The domain that you bought and want to configure
export UMAMI_HASH_SALT=************* # Random string useful for umami
export POSTGRES_USER=************* # New username for umami database
export POSTGRES_PASSWORD=************* # The password for that new user
export REMOTE_WORKING_FOLDER=/path/to/your/vps/working/folder # the root working folder on your VPS
export WEBSITE_CONTAINER_REGISTRY=************* # The container registry url as explained in the previous chapter
export WEBSITE_CONTAINER_URI=container-name:container-version # example: john/website:latest
export WEBSITE_PROJECT_PATH=/full/path/to/your/website/project/root
export VPS_ADDRESS=***.***.***.*** # the address of your VPS
```

### Set up on your local machine

1. Install docker on your machine (https://docs.docker.com/get-docker/)
2. Build your static website in a small Caddy container:
    - Build your Nextjs website and then run here
        ```bash
        # Load the environment variables
        source ./secrets/.env.qa

        # Authenticate to the external container registry
        docker login $WEBSITE_CONTAINER_REGISTRY

        # Copy the Caddyfile in your Static Website exported from NextJS
        cp ./website/nextjs/Caddyfile $WEBSITE_PROJECT_PATH/Caddyfile

        # Build the image in your NextJS project
        docker build -t $WEBSITE_CONTAINER_REGISTRY/$WEBSITE_CONTAINER_URI -f ./website/nextjs/Dockerfile $WEBSITE_PROJECT_PATH
        # - example: docker build -t registry.gitlab.com/username1/website1/website:v1.0.0 -f ./website/nextjs/Dockerfile /Users/john/website1

        # Push the container to the external container registry
        docker push $WEBSITE_CONTAINER_REGISTRY/$WEBSITE_CONTAINER_URI
        # - example: docker push registry.gitlab.com/username1/website1:v1.0.0
        ```
3. Run it locally
    ```bash
    # Load the environment variables
    source ./secrets/.env.qa

    # Run the containers passing your environment variables to the superuser user
    sudo -E docker-compose pull && sudo -E docker compose up
    ```
4. Navigate on https://localhost and https://tracking.localhost to test that everything works

### Set up on a remote server

1. Rent a VPS on your favorite VPS provider. Good examples: https://webdock.io/en, https://www.vultr.com/, https://www.linode.com/
2. Follow the readme in the [vps-setup folder](../vps-setup/README.md) to 
    1. install on the VPS all the needed dependencies
    2. push to the VPS all the file from this repository that are needed
3. Get a domain and point it on your VPS IP address
4. Build your static website in a small Caddy container and push it to a remote container registry:
    - Build your Nextjs website and then run here
        ```bash
        # Load the environment variables
        source ./secrets/.env.prod

        # Authenticate to the external container registry
        docker login $WEBSITE_CONTAINER_REGISTRY

        # Copy the Caddyfile in your Static Website exported from NextJS
        cp ./website/nextjs/Caddyfile $WEBSITE_PROJECT_PATH/Caddyfile

        # Build the image in your NextJS project
        docker build -t $WEBSITE_CONTAINER_REGISTRY/$WEBSITE_CONTAINER_URI -f ./website/nextjs/Dockerfile $WEBSITE_PROJECT_PATH
        # - example: docker build -t registry.gitlab.com/username1/website1/website:v1.0.0 -f ./website/nextjs/Dockerfile /Users/john/website1

        # Push the container to the external container registry
        docker push $WEBSITE_CONTAINER_REGISTRY/$WEBSITE_CONTAINER_URI
        # - example: docker push registry.gitlab.com/username1/website1:v1.0.0
        ```
5. Copy the necessary files on the server
    ```bash
    # Load the environment variables
    source ./secrets/.env.prod

    # Push project files on the server
    rsync -chavzP --stats \
      --include='caddy/Caddyfile' \
      --include='secrets/***' \
      --include='docker-compose.yml' \
      --exclude='*' \
      ./ $VPS_ADDRESS:$REMOTE_WORKING_FOLDER
    ```
5. SSH into the server and run the docker compose
    ```bash
    # Load the environment variables
    source ./secrets/.env.prod

    # Run the containers passing your environment variables to the superuser user
    sudo -E docker-compose pull && sudo -E docker compose up
    ```

## Usage

### Start the local (QA) environment

Locally

```bash
# Load the environment variables
source ./secrets/.env.qa

# Run the containers passing your environment variables to the superuser user
sudo -E docker compose up
```

Remotely

```bash
# Load the environment variables
source ./secrets/.env.prod

# Run the containers passing your environment variables to the superuser user
sudo -E docker compose up
```

### Deploy a new version of your website

Locally

```bash
# Load the environment variables
source ./secrets/.env.qa

# Build the image in your NextJS project
docker build -t $WEBSITE_CONTAINER_REGISTRY/$WEBSITE_CONTAINER_URI -f ./website/nextjs/Dockerfile $WEBSITE_PROJECT_PATH

# Run the containers passing your environment variables to the superuser user
sudo -E docker compose up
```

Remotely

```bash
# Load the environment variables
source ./secrets/.env.prod

# Build the image in your NextJS project
docker build -t $WEBSITE_CONTAINER_REGISTRY/$WEBSITE_CONTAINER_URI -f ./website/nextjs/Dockerfile $WEBSITE_PROJECT_PATH

# Push the container to the external container registry
docker push $WEBSITE_CONTAINER_REGISTRY/$WEBSITE_CONTAINER_URI

# Push project files on the server
rsync -chavzP --stats \
  --include='caddy/Caddyfile' \
  --include='secrets/***' \
  --include='docker-compose.yml' \
  --exclude='*' \
  ./ $VPS_ADDRESS:$REMOTE_WORKING_FOLDER

# ssh into the server and run the containers passing your environment variables to the superuser user
docker-compose pull && docker-compose up -d
```

### Download a folder for backup purposes

```bash
# Load the environment variables
source ./secrets/.env.prod

# Download recursively a folder on the server into your machine
rsync -chavzP --stats $VPS_ADDRESS:/remote/folder/path /local/folder/path
```

### Push on the server new configurations

```bash
# Load the environment variables
source ./secrets/.env.prod

# Push project files on the server
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
