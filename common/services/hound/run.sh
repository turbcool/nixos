#!/usr/bin/env bash
# Wrapper used as the MCP command for hound.
#
# Always runs in stdio mode so it works as a drop-in for opencode / Claude Code.
# For the HTTP sidecar, use:  docker compose up -d
#
# Build the image first with ./build.sh

set -euo pipefail

exec docker run \
    --rm \
    -i \
    --init \
    --network=host \
    --security-opt=no-new-privileges:true \
    hound-mcp:latest \
    "hound" "$@"
