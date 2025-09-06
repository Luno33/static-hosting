#!/bin/bash
set -e

log() {
  echo -e "\033[1;36m[update-server]\033[0m $1"
}

log "Syncing files on env $ENV towards [REDACTED]@[REDACTED]:$REMOTE_WORKING_FOLDER on port $VPS_PORT"

SSH_CMD="ssh -p $VPS_PORT"
if [[ -n "$SSH_KEY_PATH" ]]; then
  log "Uses specified key in SSH_KEY_PATH env var"
  SSH_CMD="$SSH_CMD -i $SSH_KEY_PATH"
fi

rsync -chavzP --stats \
  -e "$SSH_CMD" \
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
