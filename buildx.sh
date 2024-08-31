#!/bin/bash

if [ $# -ne 2 ]; then
    echo "usage: $0 <IMAGE_NAME> <IMAGE_TAG>"
    exit 1
fi


# Join a list of args with a single char.
# Ref: https://stackoverflow.com/a/17841619
join() { local IFS="$1"; shift; echo "$*"; }

set -ex

IMAGE_NAME="$1"
IMAGE_TAG="$2"
PLATFORMS=(
    linux/amd64
    linux/arm/v7
    linux/arm64
)

OPTS=(
    --tag "${IMAGE_NAME}:${IMAGE_TAG}"
    --platform "$(join "," "${PLATFORMS[@]}")"
    --progress=plain
    --push
)

# If the image tag is a version number, pass the corresponding version tag.
# Otherwise, build the `master` branch by default.
GIT_REF=master
if [[ "${IMAGE_TAG}" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    GIT_REF="v${IMAGE_TAG}"
    SOURCE_VERSION="${IMAGE_TAG}"
fi
opts+=(--build-arg "GIT_REF=${GIT_REF}")

SOURCE_COMMIT="$(curl -fsSL https://api.github.com/repos/gpac/gpac/commits/${GIT_REF} | jq -r .sha)"
if [[ -z "${SOURCE_VERSION}" ]]; then
    SOURCE_VERSION="${SOURCE_COMMIT}"
fi

# Use the value of the corresponding env var (if present),
# or a default value otherwise.
: "${GITHUB_REPOSITORY:=jjlin/gpac}"

# SOURCE_COMMIT="$(git rev-parse HEAD)"
# SOURCE_VERSION="$(git describe --tags --abbrev=0 --exact-match 2>/dev/null)"
# if [[ -z "${SOURCE_VERSION}" ]]; then
#     SOURCE_VERSION="${SOURCE_COMMIT}"
# fi

LABELS=(
    # https://github.com/opencontainers/image-spec/blob/master/annotations.md
    org.opencontainers.image.created="$(date --utc --iso-8601=seconds)"
    org.opencontainers.image.documentation="https://github.com/gpac/gpac/wiki"
    org.opencontainers.image.licenses="LGPL-2.1"
    org.opencontainers.image.revision="${SOURCE_COMMIT}"
    org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY}"
    org.opencontainers.image.url="https://hub.docker.com/r/${IMAGE_NAME}"
    org.opencontainers.image.version="${SOURCE_VERSION}"
)
for label in "${LABELS[@]}"; do
    OPTS+=(--label "${label}")
done

docker buildx rm builder || true
docker buildx create --name builder --driver docker-container --use --config buildkitd.toml
docker buildx inspect --bootstrap
docker buildx build "${OPTS[@]}" .

# Clean up builder.
docker buildx rm builder
