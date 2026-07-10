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
  # Secret header values use the @@SECRET:<agenix-name>@@ sentinel: the wrapper
  # substitutes them at runtime from /run/agenix/<name>, so keys never enter the
  # nix store, /etc, or the process arguments.
  claudeCode = {
    web-search-prime = {
      type = "http";
      url = "https://api.z.ai/api/mcp/web_search_prime/mcp";
      headers.Authorization = "Bearer @@SECRET:zai-token@@";
    };
  };
}
