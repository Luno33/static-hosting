SHELL=/bin/bash

# ----------- Commands to run on the development machine -----------

run-local:
	@source ./secrets/.env.qa && sudo -E docker-compose pull && sudo -E docker-compose up --remove-orphans

stop-local:
	@docker-compose down

registry-login:
	@source ./secrets/.env.prod && docker login $$WEBSITE_CONTAINER_REGISTRY

registry-logout:
	@source ./secrets/.env.prod && docker logout $$WEBSITE_CONTAINER_REGISTRY

registry-build-qa:
	@source ./secrets/.env.qa && \
	sudo -E docker build -t $$WEBSITE_CONTAINER_FULL_URI \
	-f ./website/nextjs/Dockerfile --platform $$BUILD_PLATFORM $$WEBSITE_PROJECT_PATH

registry-build-prod:
	@source ./secrets/.env.prod && \
	sudo -E docker build -t $$WEBSITE_CONTAINER_FULL_URI \
	-f ./website/nextjs/Dockerfile --platform $$BUILD_PLATFORM $$WEBSITE_PROJECT_PATH

registry-push-qa:
	@source ./secrets/.env.qa && docker push $$WEBSITE_CONTAINER_FULL_URI

registry-push-prod:
	@source ./secrets/.env.qa && docker push $$WEBSITE_CONTAINER_FULL_URI

update-server:
	@source ./secrets/.env.prod && rsync -chavzP --stats --include='caddy/' --include='caddy/Caddyfile' --include='secrets/***' --include='docker-compose.yml' --include='Makefile' --exclude='*' ./ $$VPS_USER@$$VPS_ADDRESS:$$REMOTE_WORKING_FOLDER

enter-server:
	@source ./secrets/.env.prod && ssh $$VPS_USER@$$VPS_ADDRESS

exec-caddy:
	@docker-compose exec -ti caddy /bin/bash

download-db-dump:
	@source ./secrets/.env.prod && mkdir -p ./umami/remote-db-dumps && rsync -chavzP --stats $$VPS_USER@$$VPS_ADDRESS:$$REMOTE_WORKING_FOLDER/umami/db-dumps ./umami/remote-db-dumps

# ----------- Commands to run on the remote server -----------

run-remote:
	@source ./secrets/.env.prod && docker compose pull && docker compose up -d --remove-orphans

run-db-only: # Useful to restore db dumps
	@source ./secrets/.env.prod && docker compose pull && docker compose up --no-deps --remove-orphans umami-db

dump-umami-db:
	@source ./secrets/.env.prod && docker compose exec umami-db sh -c 'pg_dump -U $$POSTGRES_USER umami > /home/db-dumps/umami-db-`date +%Y-%m-%d-%H:%M`.sql'

restore-umami-db:
	@source ./secrets/.env.prod && docker compose exec umami-db sh -c 'psql -U $$POSTGRES_USER -d umami -f /home/db-dumps/umami-db-latest.sql'
