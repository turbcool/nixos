{ lib, osConfig, ... }:

let
  llm = osConfig.local.llm;
  cleanJson = lib.filterAttrsRecursive (_: v: v != null);
in
{
  config.home.file.".config/opencode/opencode.json" = lib.mkForce {
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
        agent.explore.model = "flexberry/qwen3-coder-128k:30b";
        provider = lib.mapAttrs (name: p: {
          inherit name;
          npm = p.npm or "@ai-sdk/openai-compatible";
          models = cleanJson (p.models or { });
          options = {
            baseURL = p.url + "/v1";
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
