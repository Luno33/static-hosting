#!/bin/bash
set -e

log() {
  printf "\033[1;32m[with-env]\033[0m %s\n" "$*"
}

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") <env> [command…]"
  echo "  <env> is mandatory and can be dev, qa or prod."
  echo "  If no command is given, drops you into an interactive shell."
  exit 1
fi

unset ENV
ARG_ENV="$1"
shift

log "Loading env $ARG_ENV"
set -a
source envs/.env.$ARG_ENV
set +a
export WEBSITE_CONTAINER_FULL_URI=$(cat .deploy-assets/.image-tags/$ARG_ENV.website.tag)
export SERVICE_NAME=website

if [ $# -eq 0 ]; then
  log "✅ Env loaded; launching interactive shell…"
  exec "${SHELL:-bash}" --login
else
  log "✅ Loaded env $ENV, now running: \"$@\""
  exec "$@"
fi
