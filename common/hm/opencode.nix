{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  llm = osConfig.local.llm;
  cleanJson = lib.filterAttrsRecursive (_: v: v != null);
in
{
  config.home.file.".config/opencode/opencode.json" = lib.mkForce {
    force = true;
    text = builtins.toJSON (
      {
        "$schema" = "https://opencode.ai/config.json";
        permission = {
          webfetch = "allow";
          websearch = "allow";
          lsp = "allow";
        };
        compaction = {
          auto = true;
          prune = true;
          reserved = 16000;
        };
        disabled_providers = [ ];
        agent.explore.model = "neoplatform/qwen3-coder-128k:30b";
        # Hound MCP — baked into the global config as a streamable-HTTP server.
        # Start the sidecar with `hound` (alias) or hound-toggle().
        # Built from upstream (github.com/dondai1234/master-fetch) via
        # /etc/nixos/common/services/hound/build.sh.
        mcp.hound = {
          type = "remote";
          url = "http://localhost:8765/mcp";
          enabled = true;
        };
      }
      // {
        provider = lib.mapAttrs (name: p: {
          inherit name;
          npm = p.npm or "@ai-sdk/openai-compatible";
          models = cleanJson (
            lib.mapAttrs (_: m: builtins.removeAttrs m [ "opencode" ]) (
              lib.filterAttrs (_: m: m.opencode or true) (p.models or { })
            )
          );
          options = {
            baseURL = p.url;
            apiKey = if p ? tokenFile then "{file:${osConfig.age.secrets."${name}-token".path}}" else "";
          };
        }) llm.providers;
      }
      // lib.optionalAttrs (llm.defaultModel != null) {
        model = llm.defaultModel;
        small_model = llm.smallModel;
      }
    );
  };
}
