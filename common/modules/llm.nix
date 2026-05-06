{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.llm;
  providers = import ../../config/providers.nix;
  username = config.local.profile.username;

  hasToken = lib.filterAttrs (_: p: p ? tokenFile);

  cleanJson = lib.filterAttrsRecursive (_: v: v != null);
in
{
  options.local.llm = {
    defaultModel = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    smallModel = lib.mkOption {
      type = lib.types.str;
      default = cfg.defaultModel;
    };

    opencodeJson = lib.mkOption {
      type = lib.types.attrs;
      internal = true;
    };
  };

  config = {
    environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      agent-deck
      opencode
    ];

    age.secrets = lib.mapAttrs' (name: p: {
      name = "${name}-token";
      value = {
        file = p.tokenFile;
        owner = username;
        mode = "0400";
      };
    }) (hasToken providers);

    local.llm = {
      defaultModel = "qwen3-coder-128k:30b";
      opencodeJson = {
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
        provider = lib.mapAttrs (name: p: {
          inherit name;
          npm = p.npm or "@ai-sdk/openai-compatible";
          models = cleanJson (p.models or { });
          options = {
            baseURL = p.url;
            apiKey = if p ? tokenFile then "{file:${config.age.secrets."${name}-token".path}}" else "";
          };
        }) providers;
      }
      // lib.optionalAttrs (cfg.defaultModel != null) {
        model = cfg.defaultModel;
        small_model = cfg.smallModel;
      };
    };
  };
}
