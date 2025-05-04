#!/bin/bash
set -e

log() {
  printf "\033[1;32m[with-env]\033[0m %s\n" "$*"
}

unset ENV
ARG_ENV="$1"
shift

log "Loading env $ARG_ENV"
source envs/.env.$ARG_ENV
export WEBSITE_CONTAINER_FULL_URI=$(cat .deploy-assets/.image-tags/$ARG_ENV.website.tag)
export SERVICE_NAME=website

log "✅ Loaded env $ENV, now running: \"$@\""

exec "${@}"
