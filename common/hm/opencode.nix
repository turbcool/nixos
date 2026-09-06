{
  inputs,
  lib,
  osConfig,
  pkgs,
  config,
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
        plugin = [
          "${inputs.ponytail}/.opencode/plugins/ponytail.mjs"
        ];
        agent.explore.model = llm.smallModel;
        # Absolute paths: MCP servers inherit the agent's environment, which
        # may predate home.sessionPath (e.g. GUI-launched) — never rely on PATH.
        mcp.donsetch = {
          type = "local";
          command = [ "${config.home.homeDirectory}/.npm/bin/donsetch" "mcp" ];
          enabled = true;
        };
        mcp.bladebro = {
          type = "local";
          command = [ "${config.home.homeDirectory}/.npm/bin/bladebro" "mcp" ];
          enabled = true;
        };
      }
      // {
        provider = lib.mapAttrs (name: p: {
          inherit name;
          npm = "@ai-sdk/openai-compatible";
          models = cleanJson (p.models or { });
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
