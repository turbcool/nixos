#!/usr/bin/env bash
# Wrapper used as the opencode MCP command for hound. Spawns an ephemeral
# container per MCP session and pipes its stdio through to the host.
#
# Kept in the repo (under common/services/hound/) so the MCP config can
# reference a single stable path. Any pre-existing `hound-mcp` container
# is left alone; --rm cleans up on exit.
exec docker run \
    --rm \
    -i \
    --init \
    --network=host \
    --security-opt=no-new-privileges:true \
    hound-mcp:latest \
    "$@"
