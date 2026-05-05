{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.llm;
  username = config.local.profile.username;
  llmLib = import ../../lib/llm.nix lib;

  tokenPresent = llmLib.filterPresent cfg.providers;
in

{
  options.local.llm = {
    providers = lib.mkOption {
      type = lib.types.attrsOf llmLib.providerType;
      default = { };
    };

    defaultProvider = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    defaultModel = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    smallModel = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = cfg.defaultModel;
    };

    opencodeProviders = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      internal = true;
    };
  };

  config = {
    environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      agent-deck
      opencode
    ];

    age.secrets = llmLib.mkAgeSecrets tokenPresent username;

    local.llm = {
      providers = import ../../lib/providers.nix { secretsDir = ../secrets; };
      defaultProvider = "flexberry";
      defaultModel = "qwen3-coder-128k:30b";
      opencodeProviders = llmLib.mkOpencodeProviders cfg.providers tokenPresent config.age.secrets;
    };

    warnings = llmLib.mkWarnings (llmLib.filterMissing cfg.providers);
  };
}
