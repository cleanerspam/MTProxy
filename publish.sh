#!/bin/bash

# Exit on error
set -e
# Enable verbose debugging
set -x

# Redirect all output (stdout and stderr) to savelog.txt while still showing it on screen
exec > >(tee -a savelog.txt) 2>&1

echo "Build started at $(date)"

# Default username for Docker Hub
USERNAME=${1:-myuser}
IMAGE_NAME="mtproxy"

# Extract version from git
if command -v git &> /dev/null && [ -d .git ]; then
    if git describe --tags >/dev/null 2>&1; then
        VERSION=$(git describe --tags)
    else
        VERSION=$(git rev-parse --short HEAD)
    fi
else
    # Fallback to date if not a git repo or git missing
    VERSION=$(date +%Y%m%d)
    echo "Warning: No git repository found. Using date as version: $VERSION"
fi

echo "----------------------------------------------------"
echo "Publishing $USERNAME/$IMAGE_NAME:$VERSION"
echo "Platforms: linux/amd64, linux/arm64, linux/arm/v7, linux/riscv64, linux/s390x, linux/ppc64le, linux/386"
echo "----------------------------------------------------"

# Initialize buildx
# check if builder exists
if ! docker buildx inspect mtproxy-builder > /dev/null 2>&1; then
    echo "Creating new buildx builder 'mtproxy-builder'..."
    docker buildx create --name mtproxy-builder --use
else
    echo "Using existing buildx builder 'mtproxy-builder'..."
    docker buildx use mtproxy-builder
fi

# Bootstrap builder
docker buildx inspect --bootstrap

# Build and Push
echo "Building and pushing..."
docker buildx build \
  --no-cache \
  --progress=plain \
  --platform linux/amd64,linux/arm64,linux/arm/v7,linux/riscv64,linux/s390x,linux/ppc64le,linux/386 \
  -t "$USERNAME/$IMAGE_NAME:latest" \
  -t "$USERNAME/$IMAGE_NAME:$VERSION" \
  --push \
  .

echo "----------------------------------------------------"
echo "Successfully published to Docker Hub!"
echo "Tags:"
echo "  - $USERNAME/$IMAGE_NAME:latest"
echo "  - $USERNAME/$IMAGE_NAME:$VERSION"
echo "----------------------------------------------------"
echo "Build finished at $(date)"
