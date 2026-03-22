## Start the containers

```bash
# With docker compose running on the pc
make run-local ENV=dev

# With docker compose running on the vm (run it inside the VM)
make run-remote ENV=qa

# With docker compose running on the server (run it inside the VPS)
make run-remote ENV=prod
```

## Stop the containers

```bash
# With docker compose running on the pc
make stop-local ENV=dev

# With docker compose running on the vm (run it inside the VM)
make stop-remote ENV=qa

# With docker compose running on the server (run it inside the VPS)
make stop-remote ENV=prod
```

## Dump the PostgreSQL DB

```bash
# From inside the VM
make run-db-only ENV=qa
make dump-umami-db ENV=qa

# From inside the VPS
make run-db-only ENV=prod
make dump-umami-db ENV=prod
```

And then, once the DB dump is created:

```bash
# From the dev laptop, fetching the dump from QA
make download-db-dump ENV=qa

# From the dev laptop, fetching the dump from PROD
make download-db-dump ENV=prod
```

## Restore the PostgreSQL DB

With this process we load on `qa` a dump of the Umami DB fetched from `prod`

```bash
# List the remote dumps available from the dev laptop
ls -la ./umami/remote-db-dumps/db-dumps/
# Copy the db dump you want to restore on the qa VM and give it the fixed name "umami-db-restore.sql"
cp ./umami/remote-db-dumps/db-dumps/<filename-of-the-dump-to-restore>.sql ./umami/remote-db-dumps/db-dumps/umami-db-restore.sql
make upload-db-dump ENV=qa

# Enter the qa VM
make enter-server ENV=qa
# Load the prod db dump
make restore-umami-db ENV=qa
```

## Download a folder for backup purposes

```bash
# Load the environment variables
source /envs/.env.prod

# Download recursively a folder on the server into your machine
rsync -chavzP --stats $VPS_ADDRESS:/remote/folder/path /local/folder/path
```

## Push on the server new configurations and files

```bash
# For the QA VM
make update-server ENV=qa

# For the production VPS
make update-server ENV=prod
```

## Load env vars in current shell

Useful for loading them up and then debug freely having all the environmental variables loaded up of the specified environment:

```bash
./scripts/with-env.sh <env>
# Example
# ./scripts/with-env.sh dev
# ./scripts/with-env.sh qa
# ./scripts/with-env.sh prod
```

## Check Caddy logs

```bash
# From inside the QA VM
make run caddy-logs ENV=qa

# From inside the Production VPS
make run caddy-logs ENV=prod
```