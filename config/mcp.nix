{
  nixos = {
    type = "local";
    command = [ "mcp-nixos" ];
    enabled = true;
  };
  daisyui = {
    type = "local";
    command = [
      "docker"
      "run"
      "-i"
      "--rm"
      "daisyui-mcp"
    ];
    enabled = true;
  };
  svelte = {
    type = "remote";
    url = "https://mcp.svelte.dev/mcp";
    enabled = true;
  };
  lucide-icons = {
    type = "local";
    command = [
      "npx"
      "lucide-icons-mcp"
      "--stdio"
    ];
    enabled = true;
  };

  wiki = {
    type = "local";
    command = [ "qmd" "mcp" ];
    enabled = true;
  };

  # Hound MCP — web fetch / crawl / search with Patchright anti-bot bypass and
  # optional PDF+OCR (via the [all] extras). Runs as a Docker HTTP sidecar.
  #
  # Build:  /etc/nixos/common/services/hound/build.sh
  #   Clones upstream (https://github.com/dondai1234/master-fetch) to ~/hound-mcp
  #   and builds from its Dockerfile (no local fork).
  # Start:  /etc/nixos/common/services/hound/serve.sh
  #   Listens on http://localhost:8765/mcp (streamable-HTTP MCP transport).
  # Stop:   docker compose -f ~/hound-mcp/docker-compose.yml down
  hound = {
    type = "remote";
    url = "http://localhost:8765/mcp";
    enabled = true;
  };

  groups = {
    nixos = [ "nixos" ];
    frontend = [ "svelte" "daisyui" "lucide-icons"];
    wiki = [ "wiki" ];
  };

  # ── Claude Code (the `claude` CLI) MCP servers ────────────────────────────
  # Native Claude Code schema, kept separate from the opencode-style registry
  # above (the two schemas differ). The `claude` wrapper in common/hm/cli.nix
  # turns this into a runtime --mcp-config file.
  #
  # Both schemas use the HTTP streamable transport. Start the sidecar first:
  #   /etc/nixos/common/services/hound/serve.sh
  #
  # Secret header values use the @@SECRET:<agenix-name>@@ sentinel: the wrapper
  # substitutes them at runtime from /run/agenix/<name>, so keys never enter the
  # nix store, /etc, or the process arguments.
  claudeCode = {
    hound = {
      type = "url";
      url = "http://localhost:8765/mcp";
    };
  };
}
