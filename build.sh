#!/bin/bash
set -e

IMAGE_NAME="mtproxy"
TAG="latest"
PLATFORMS="linux/amd64,linux/arm64"

echo "Preparing multi-arch build for: $PLATFORMS"

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: docker is not installed."
    exit 1
fi

# Create a new builder instance if it doesn't exist
if ! docker buildx inspect mtproxy-builder > /dev/null 2>&1; then
    echo "Creating new buildx builder: mtproxy-builder"
    docker buildx create --name mtproxy-builder --use
    docker buildx inspect --bootstrap
else
    echo "Using existing builder: mtproxy-builder"
    docker buildx use mtproxy-builder
fi

# Build (and optionally push)
echo "Building for CURRENT architecture ($(uname -m)) and loading..."

# Auto-detect current arch for local load
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" ]]; then DOCKER_ARCH="linux/arm64"; else DOCKER_ARCH="linux/amd64"; fi

docker buildx build --platform $DOCKER_ARCH -t "${IMAGE_NAME}:latest" --load .

echo "Done! Image ${IMAGE_NAME}:latest available locally for testing."
