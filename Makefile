SHELL=/bin/bash

run-local:
	@echo "Loading QA environment variables..."
	@source ./secrets/.env.qa && echo "Running containers..." && sudo -E docker-compose pull && sudo -E docker-compose up

stop-local:
	@docker-compose down

exec-caddy:
	@docker-compose exec -ti caddy /bin/bash
