#!/usr/bin/env bash
# Start the Hound HTTP sidecar from the upstream repo.
# Exposes streamable-HTTP MCP on http://localhost:8765/mcp
#
# Prerequisites: run ./build.sh first (clones upstream to ~/hound-mcp).
# Stop with: docker compose -f ~/hound-mcp/docker-compose.yml down

set -euo pipefail
exec docker compose \
    -f "${HOME}/hound-mcp/docker-compose.yml" \
    up -d --wait
