#!/bin/bash

if [ $# -ne 2 ]; then
    echo "usage: $0 <IMAGE_NAME> <IMAGE_TAG>"
    exit 1
fi

IMAGE_NAME="$1"
IMAGE_TAG="$2"

opts=(
    --tag "${IMAGE_NAME}:${IMAGE_TAG}"
)

# If the image tag is a version number, pass
if [[ "${IMAGE_TAG}" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    opts+=(--build-arg "v${IMAGE_TAG}")
fi

docker build "${opts[@]}" .
