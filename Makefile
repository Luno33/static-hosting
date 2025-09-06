SHELL=/bin/bash

# ----------- Commands to run on the development machine -----------

build-image:
	bash ./scripts/with-env.sh $(ENV) ./scripts/build-image.sh

run-local:
	bash ./scripts/with-env.sh $(ENV) sudo -E docker compose up --remove-orphans

stop-local:
	bash ./scripts/with-env.sh $(ENV) sudo -E docker compose down

build-and-run:
	make build-image ENV=$(ENV)
	make run-local ENV=$(ENV)

build-and-deploy:
	make build-image ENV=$(ENV)
	make update-server ENV=$(ENV)
	bash ./scripts/with-env.sh $(ENV) ./scripts/remote-deploy.sh

update-server:
	bash ./scripts/with-env.sh $(ENV) ./scripts/update-server.sh

enter-server:
	bash ./scripts/with-env.sh $(ENV) ./scripts/enter-server.sh

exec-caddy:
	bash ./scripts/with-env.sh $(ENV) sudo -E docker compose exec -ti caddy sh

download-db-dump:
	mkdir -p ./umami/remote-db-dumps && bash ./scripts/with-env.sh $(ENV) bash -c 'rsync -chavzP -e "ssh -p $$VPS_PORT" --stats "$$VPS_USER@$$VPS_ADDRESS:$$REMOTE_WORKING_FOLDER/umami/db-dumps" ./umami/remote-db-dumps'

upload-db-dump:
	bash ./scripts/with-env.sh $(ENV) rsync -chavzP --stats -e "ssh -p $$VPS_PORT" 'umami/remote-db-dumps/db-dumps/umami-db-latest.sql' "$$VPS_USER@$$VPS_ADDRESS:$$REMOTE_WORKING_FOLDER/restore-db-dump/"

# ----------- Commands to run on the remote server -----------

run-remote:
	bash ./scripts/with-env.sh $(ENV) docker compose up --remove-orphans

stop-remote:
	bash ./scripts/with-env.sh $(ENV) docker compose down

run-db-only: # Useful to restore db dumps
	bash ./scripts/with-env.sh $(ENV) docker compose up --no-deps --remove-orphans umami-db

dump-umami-db:
	bash ./scripts/with-env.sh $(ENV) docker compose exec umami-db sh -c 'pg_dump -U $$POSTGRES_USER umami > /home/db-dumps/umami-db-`date +%Y-%m-%d-%H:%M`.sql'

restore-umami-db:
	bash ./scripts/with-env.sh $(ENV) docker compose exec umami-db sh -c 'psql -U $$POSTGRES_USER -d umami -f /home/db-dumps/umami-db-latest.sql'

caddy-logs:
	bash ./scripts/with-env.sh $(ENV) docker logs caddy
