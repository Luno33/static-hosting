#!/bin/bash
set -e

log() {
  printf "\033[1;34m[build-image]\033[0m %s\n" "$*"
}

# This script assumes environment variables are already loaded by with-env.sh

log "Using env $ENV..."

log "Reading git SHA..."
GIT_SHA=$(git -C "$WEBSITE_PROJECT_PATH" rev-parse --short=7 HEAD)
IMAGE_TAG="$ENV-$GIT_SHA"
IMAGE_URI="$SERVICE_NAME:$IMAGE_TAG"

log "Generated image tag: $IMAGE_URI"
log "Saving tag to .deploy-assets/.image-tags/$ENV.$SERVICE_NAME.tag"
echo "$IMAGE_URI" > ".deploy-assets/.image-tags/$ENV.$SERVICE_NAME.tag"

log "Building Docker image..."
sudo -E docker build \
  --build-arg ENV_FILE=".env-build-$ENV" \
  --build-arg IMAGE_URI="$IMAGE_URI" \
  --platform "$BUILD_PLATFORM" \
  -t "$IMAGE_URI" \
  -f ./website/nextjs/Dockerfile \
  "$WEBSITE_PROJECT_PATH"

log "Saving Docker image to tar.gz..."
sudo -E docker save "$IMAGE_URI" | gzip > ".deploy-assets/.image-tars/$ENV.$IMAGE_URI.tar.gz"

log "✅ Image build and save complete: $IMAGE_URI"
