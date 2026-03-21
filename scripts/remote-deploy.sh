#!/bin/bash
set -e

log() {
  printf "\033[1;32m[remote-deploy:local]\033[0m %s\n" "$*"
}

log "Deploying to $ENV..."

SSH_CMD="ssh -p $VPS_PORT"
if [[ -n "$SSH_KEY_PATH" ]]; then
  log "Uses specified key in SSH_KEY_PATH env var"
  SSH_CMD="$SSH_CMD -i $SSH_KEY_PATH"
fi

$SSH_CMD "$VPS_USER@$VPS_ADDRESS" -p $VPS_PORT bash -s <<EOF
  set -e

  log() {
    printf "\033[1;32m[remote-deploy:remote]\033[0m %s\n" "\$1"
  }

  cd "$REMOTE_WORKING_FOLDER"
  log "Working directory: \$PWD"
  
  log "Loading envs from envs/.env.$ENV"
  set -a
  source envs/.env.$ENV
  set +a

  log "Fetching image tag..."
  WEBSITE_IMAGE=\$(cat .deploy-assets/.image-tags/$ENV.website.tag)
  log "Image: \$WEBSITE_IMAGE"

  log "Loading image into local registry..."
  podman load < .deploy-assets/.image-tars/$ENV.\$WEBSITE_IMAGE.tar.gz

  log "Stopping current containers..."
  WEBSITE_CONTAINER_FULL_URI=\$WEBSITE_IMAGE \
  podman compose down --remove-orphans

  log "Starting new containers..."
  WEBSITE_CONTAINER_FULL_URI=\$WEBSITE_IMAGE \
  podman compose up -d --remove-orphans

  log "Ensuring systemd service is configured..."
  mkdir -p ~/.config/systemd/user

  cat > ~/.config/systemd/user/podman-compose-app.service << 'SERVICE_EOF'
[Unit]
Description=Podman Compose - app
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=__WORKING_DIR__

ExecStart=/usr/bin/make run-remote ENV=__ENV__
ExecStop=/usr/bin/make stop-remote ENV=__ENV__

[Install]
WantedBy=default.target
SERVICE_EOF

  sed -i "s|__WORKING_DIR__|$REMOTE_WORKING_FOLDER|g" ~/.config/systemd/user/podman-compose-app.service
  sed -i "s|__ENV__|$ENV|g" ~/.config/systemd/user/podman-compose-app.service

  systemctl --user daemon-reload
  systemctl --user enable podman-compose-app.service
  log "Systemd service enabled"
EOF
