SHELL=/bin/bash

ENV ?= qa
ENV_FILE := ./envs/.env.$(ENV)

# ----------- Commands to run on the development machine -----------

run-local:
	@source $(ENV_FILE) && sudo -E docker compose pull && sudo -E docker compose up --remove-orphans

stop-local:
	@source $(ENV_FILE) && docker compose down

registry-login:
	@source $(ENV_FILE) && docker login $$WEBSITE_CONTAINER_REGISTRY

registry-logout:
	@source $(ENV_FILE) && docker logout $$WEBSITE_CONTAINER_REGISTRY

registry-build:
	@source $(ENV_FILE) && \
	sudo -E docker build -t $$WEBSITE_CONTAINER_FULL_URI \
	-f ./website/nextjs/Dockerfile --platform $$BUILD_PLATFORM $$WEBSITE_PROJECT_PATH

registry-push:
	@source $(ENV_FILE) && docker push $$WEBSITE_CONTAINER_FULL_URI

update-server:
	@source $(ENV_FILE) && rsync -chavzP --stats --include='caddy/' --include='caddy/Caddyfile' --include='envs/***' --include='docker-compose.yml' --include='Makefile' --exclude='*' ./ $$VPS_USER@$$VPS_ADDRESS:$$REMOTE_WORKING_FOLDER

enter-server:
	@source $(ENV_FILE) && ssh $$VPS_USER@$$VPS_ADDRESS

exec-caddy:
	@source $(ENV_FILE) && docker compose exec -ti caddy sh

download-db-dump:
	@source $(ENV_FILE) && mkdir -p ./umami/remote-db-dumps && rsync -chavzP --stats $$VPS_USER@$$VPS_ADDRESS:$$REMOTE_WORKING_FOLDER/umami/db-dumps ./umami/remote-db-dumps

# ----------- Commands to run on the remote server -----------

run-remote:
	@source $(ENV_FILE) && docker compose pull && docker compose up -d --remove-orphans

stop-remote:
	@source $(ENV_FILE) && docker compose down

run-db-only: # Useful to restore db dumps
	@source $(ENV_FILE) && docker compose pull && docker compose up --no-deps --remove-orphans umami-db

dump-umami-db:
	@source $(ENV_FILE) && docker compose exec umami-db sh -c 'pg_dump -U $$POSTGRES_USER umami > /home/db-dumps/umami-db-`date +%Y-%m-%d-%H:%M`.sql'

restore-umami-db:
	@source $(ENV_FILE) && docker compose exec umami-db sh -c 'psql -U $$POSTGRES_USER -d umami -f /home/db-dumps/umami-db-latest.sql'
