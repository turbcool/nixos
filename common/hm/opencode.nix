{
  inputs,
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
        plugin = [
          "${inputs.ponytail}/.opencode/plugins/ponytail.mjs"
        ];
        agent.explore.model = llm.smallModel;
        mcp.donsetch = {
          type = "local";
          command = [ "donsetch" "mcp" ];
          enabled = true;
        };
        mcp.bladebro = {
          type = "local";
          command = [ "bladebro" "mcp" ];
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
