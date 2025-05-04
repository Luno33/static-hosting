SHELL=/bin/bash

ENV_FILE := ./envs/.env.$(ENV)

guard-%:
	@ if [ -z "$($*)" ]; then \
		echo "ERROR: Missing required variable '$*' (e.g. ENV=dev)"; \
		exit 1; \
	fi

# ----------- Commands to run on the development machine -----------

build-image: guard-ENV
	@source $(ENV_FILE) && \
	GIT_SHA=$$(git -C $$WEBSITE_PROJECT_PATH rev-parse --short=7 HEAD) && \
	IMAGE_TAG=$(ENV)-$$GIT_SHA && \
	SERVICE_NAME=website && \
	IMAGE_URI=$$SERVICE_NAME:$$IMAGE_TAG && \
	echo "$$IMAGE_URI" > .deploy-assets/.image-tags/$(ENV).$$SERVICE_NAME.tag && \
	sudo -E docker build \
		--build-arg ENV_FILE=.env-build-$(ENV) \
		--build-arg IMAGE_URI=$$IMAGE_URI \
		--platform $$BUILD_PLATFORM \
		-t $$IMAGE_URI \
		-f ./website/nextjs/Dockerfile \
		$$WEBSITE_PROJECT_PATH && \
	sudo -E docker save $$IMAGE_URI | gzip > .deploy-assets/.image-tars/$(ENV).$$SERVICE_NAME.tar.gz

run-local: guard-ENV
	@source $(ENV_FILE) && \
	WEBSITE_IMAGE=$$(cat .deploy-assets/.image-tags/$(ENV).website.tag) && \
	COMPOSE_PROJECT_NAME=$(ENV) && \
	env WEBSITE_CONTAINER_FULL_URI=$$WEBSITE_IMAGE sudo -E docker compose up --remove-orphans

stop-local: guard-ENV
	@source $(ENV_FILE) && \
	WEBSITE_IMAGE=$$(cat .deploy-assets/.image-tags/$(ENV).website.tag) && \
	env WEBSITE_CONTAINER_FULL_URI=$$WEBSITE_IMAGE docker compose down

build-and-run: guard-ENV
	make build-image ENV=$(ENV)
	make run-local ENV=$(ENV)

build-and-deploy: guard-ENV
	make build-image ENV=$(ENV)
	make update-server ENV=$(ENV)
	@source $(ENV_FILE) && \
	ssh $$VPS_USER@$$VPS_ADDRESS "\
		cd $$REMOTE_WORKING_FOLDER && pwd && \
		echo 'Load env vars of:' envs/.env.$(ENV) && \
		set -a && source envs/.env.$(ENV) && set +a && \
		echo 'Load image tar into local registry, it might take a while...' && \
		docker load < .deploy-assets/.image-tars/$(ENV).website.tar.gz && \
		echo 'Fetch latest image tag' && \
		WEBSITE_IMAGE=\$$(cat .deploy-assets/.image-tags/$(ENV).website.tag) && \
		echo 'Deploy image:' \$$WEBSITE_IMAGE && \
		COMPOSE_PROJECT_NAME=$(ENV) && \
		WEBSITE_CONTAINER_FULL_URI=\$$WEBSITE_IMAGE \
		docker compose up -d --no-recreate --remove-orphans"

update-server: guard-ENV
	@source $(ENV_FILE) && rsync -chavzP --stats --include='caddy/' --include='caddy/Caddyfile' --include='envs/***' --include='docker-compose.yml' --include='Makefile' --include='.deploy-assets/***' --exclude='*' ./ $$VPS_USER@$$VPS_ADDRESS:$$REMOTE_WORKING_FOLDER

enter-server: guard-ENV
	@source $(ENV_FILE) && ssh $$VPS_USER@$$VPS_ADDRESS

exec-caddy: guard-ENV
	@source $(ENV_FILE) && \
	WEBSITE_IMAGE=$$(cat .deploy-assets/.image-tags/$(ENV).website.tag) && \
	env WEBSITE_CONTAINER_FULL_URI=$$WEBSITE_IMAGE sudo -E docker compose exec -ti caddy sh

download-db-dump: guard-ENV
	@source $(ENV_FILE) && mkdir -p ./umami/remote-db-dumps && rsync -chavzP --stats $$VPS_USER@$$VPS_ADDRESS:$$REMOTE_WORKING_FOLDER/umami/db-dumps ./umami/remote-db-dumps

# ----------- Commands to run on the remote server -----------

# run-remote: guard-ENV
# 	@source $(ENV_FILE) && \
# 	WEBSITE_IMAGE=$$(cat .deploy-assets/.image-tags/$(ENV).website.tag) && \
# 	COMPOSE_PROJECT_NAME=$(ENV) && \
# 	env WEBSITE_CONTAINER_FULL_URI=$$WEBSITE_IMAGE sudo -E docker compose up --remove-orphans

# stop-remote: guard-ENV
# 	@source $(ENV_FILE) && docker compose down

# run-db-only: guard-ENV # Useful to restore db dumps
# 	@source $(ENV_FILE) && docker compose pull && docker compose up --no-deps --remove-orphans umami-db

# dump-umami-db: guard-ENV
# 	@source $(ENV_FILE) && docker compose exec umami-db sh -c 'pg_dump -U $$POSTGRES_USER umami > /home/db-dumps/umami-db-`date +%Y-%m-%d-%H:%M`.sql'

# restore-umami-db: guard-ENV
# 	@source $(ENV_FILE) && docker compose exec umami-db sh -c 'psql -U $$POSTGRES_USER -d umami -f /home/db-dumps/umami-db-latest.sql'

# caddy-logs: guard-ENV
# 	@source $(ENV_FILE) && docker logs caddy
