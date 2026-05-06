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

  hasToken = lib.filterAttrs (_: p: p ? tokenFile);
in
{
  options.local.llm = {
    providers = lib.mkOption {
      type = lib.types.attrs;
      default = import ../../config/providers.nix;
    };

    defaultModel = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    smallModel = lib.mkOption {
      type = lib.types.str;
      default = cfg.defaultModel;
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
    }) (hasToken cfg.providers);

    local.llm.defaultModel = "qwen3-coder-128k:30b";
  };
}
