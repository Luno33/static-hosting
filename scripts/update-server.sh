#!/bin/bash
set -e

log() {
  echo -e "\033[1;36m[update-server]\033[0m $1"
}

log "Syncing files on env $ENV towards [REDACTED]@[REDACTED]:$REMOTE_WORKING_FOLDER"

rsync -chavzP --stats \
  --include='caddy/' \
  --include='caddy/Caddyfile' \
  --include='envs/***' \
  --include='docker-compose.yml' \
  --include='Makefile' \
  --include='.deploy-assets/***' \
  --include='scripts/***' \
  --exclude='*' \
  ./ "$VPS_USER@$VPS_ADDRESS:$REMOTE_WORKING_FOLDER"

log "✅ Sync complete."
