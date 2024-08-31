SHELL=/bin/bash

run-local:
	@source ./secrets/.env.qa && sudo -E docker-compose pull && sudo -E docker-compose up

stop-local:
	@docker-compose down

registry-login:
	@source ./secrets/.env.qa && docker login ${WEBSITE_CONTAINER_REGISTRY}

registry-build:
	@source ./secrets/.env.qa && sudo -E docker build -t ${WEBSITE_CONTAINER_REGISTRY}/${WEBSITE_CONTAINER_URI} -f ./website/nextjs/Dockerfile ${WEBSITE_PROJECT_PATH}

update-server:
	@source ./secrets/.env.prod && rsync -chavzP --stats --include='caddy/' --include='caddy/Caddyfile' --include='secrets/***' --include='docker-compose.yml' --include='Makefile' --exclude='*' ./ ${VPS_USER}@${VPS_ADDRESS}:${REMOTE_WORKING_FOLDER}

enter-server:
	@source ./secrets/.env.prod && ssh ${VPS_USER}@${VPS_ADDRESS}

exec-caddy:
	@docker-compose exec -ti caddy /bin/bash