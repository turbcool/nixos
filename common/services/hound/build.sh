#!/usr/bin/env bash
# Clone/update the upstream master-fetch repo to ~/hound-mcp and build the
# Docker image from its Dockerfile (not a local fork).
#
# Usage:  ./build.sh [tag]                    # default: hound-mcp:latest
#         ./build.sh hound-mcp:latest --no-cache
set -euo pipefail

repo_dir="${HOME}/hound-mcp"
upstream="https://github.com/dondai1234/master-fetch.git"
tag="${1:-hound-mcp:latest}"
image="${tag%%:*}"
shift 2>/dev/null || true

# Clone or pull the upstream repo
if [[ -d "${repo_dir}/.git" ]]; then
    echo "→ Updating ${repo_dir} …"
    git -C "${repo_dir}" fetch --depth=1 origin
    git -C "${repo_dir}" reset --hard origin/master
else
    echo "→ Cloning ${upstream} → ${repo_dir} …"
    git clone --depth=1 "${upstream}" "${repo_dir}"
fi

cd "${repo_dir}"

echo "→ Building ${tag} from upstream Dockerfile …"
docker build \
    "${@}" \
    -t "${tag}" \
    .

# Also tag as :latest so the MCP config always resolves
if [[ "${tag}" != *":latest" ]]; then
    docker tag "${image}:${tag#*:}" "${image}:latest"
fi

echo "✓ Built ${tag}"
docker images "${image}" --format "  {{.Repository}}:{{.Tag}}\t{{.Size}}"
