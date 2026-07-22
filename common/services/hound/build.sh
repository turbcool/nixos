#!/usr/bin/env bash
# Build the hound-mcp Docker image. Run from this directory.
#
# Usage:  ./build.sh [tag]        # default tag: hound-mcp:latest
set -euo pipefail

cd "$(dirname "$0")"

tag="${1:-hound-mcp:latest}"
image="hound-mcp"

docker build -t "${image}:${tag#*:}" .
# Also tag as :latest for the MCP config which references the bare name.
if [[ "${tag}" != *":latest" ]]; then
    docker tag "${image}:${tag#*:}" "${image}:latest"
fi

echo "✓ Built ${image}:${tag#*:}"
docker images "${image}" --format "  {{.Repository}}:{{.Tag}}\t{{.Size}}"
