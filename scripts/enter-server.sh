#!/usr/bin/env bash
set -e

if [[ -z "$VPS_USER" || -z "$VPS_ADDRESS" || -z "$REMOTE_WORKING_FOLDER" || -z "$VPS_PORT" ]]; then
  echo "[enter-server] Missing required env variables."
  echo "Make sure VPS_USER, VPS_ADDRESS, VPS_PORT, and REMOTE_WORKING_FOLDER are set."
  exit 1
fi

echo "[enter-server] Connecting to [REDACTED]@[REDACTED] and entering $REMOTE_WORKING_FOLDER"

SSH_CMD="ssh -p $VPS_PORT"
if [[ -n "$SSH_KEY_PATH" ]]; then
  echo "[enter-server] Uses specified key in SSH_KEY_PATH env var"
  SSH_CMD="$SSH_CMD -i $SSH_KEY_PATH"
fi

exec $SSH_CMD -p $VPS_PORT -t "$VPS_USER@$VPS_ADDRESS" "cd '$REMOTE_WORKING_FOLDER'; exec bash -l"
