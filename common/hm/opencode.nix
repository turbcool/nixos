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
        # Hound MCP — baked into the global config so it follows the user into
        # every project (not just ones where they remembered to run
        # `mcp hound`). Runs in an ephemeral Docker container via run.sh; the
        # image is built from common/services/hound/.
        mcp.hound = {
          type = "local";
          command = [ "/etc/nixos/common/services/hound/run.sh" ];
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
