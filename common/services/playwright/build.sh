#!/usr/bin/env bash
# Build custom playwright Docker image with custom CA certificates baked in.
#
# Usage:  ./build.sh [tag]                    # default: playwright-mcp:latest
#         ./build.sh playwright-mcp:latest --no-cache
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
tag="${1:-playwright-mcp:latest}"
shift 2>/dev/null || true

# Temp build context
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

cp "$script_dir/Dockerfile" "$build_dir/"
mkdir -p "$build_dir/certs"
cp "$repo_root/common/modules/cert/"*.crt "$build_dir/certs/"

echo "-> Building ${tag} …"
docker build "$@" -t "${tag}" "${build_dir}"

# Also tag as :latest
if [[ "${tag}" != *":latest" ]]; then
    docker tag "${tag%%:*}:${tag#*:}" "${tag%%:*}:latest"
fi

echo "✓ Built ${tag}"
docker images "${tag%%:*}" --format "  {{.Repository}}:{{.Tag}}\t{{.Size}}"
