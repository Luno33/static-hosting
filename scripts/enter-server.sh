#!/usr/bin/env bash
set -e

if [[ -z "$VPS_USER" || -z "$VPS_ADDRESS" || -z "$REMOTE_WORKING_FOLDER" ]]; then
  echo "[enter-server] Missing required env variables."
  echo "Make sure VPS_USER, VPS_ADDRESS, and REMOTE_WORKING_FOLDER are set."
  exit 1
fi

echo "[enter-server] Connecting to [REDACTED]@[REDACTED] and entering $REMOTE_WORKING_FOLDER"
exec ssh -t "$VPS_USER@$VPS_ADDRESS" "cd '$REMOTE_WORKING_FOLDER'; exec bash -l"
