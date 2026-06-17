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

  cc = cfg.claudeCode;
  ccProvider = cfg.providers.${cc.provider};
  ccTokenPath = config.age.secrets."${cc.provider}-token".path;
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

    claudeCode = {
      enable = lib.mkEnableOption "Claude Code integration" // {
        default = true;
      };

      provider = lib.mkOption {
        type = lib.types.str;
        default = "zai";
      };

      models = {
        opus = lib.mkOption {
          type = lib.types.str;
          default = "glm-5.2[1m]";
        };
        sonnet = lib.mkOption {
          type = lib.types.str;
          default = "glm-5.2[1m]";
        };
        haiku = lib.mkOption {
          type = lib.types.str;
          default = "glm-4.5-air";
        };
        subagent = lib.mkOption {
          type = lib.types.str;
          default = "glm-5.2[1m]";
        };
      };
    };
  };

  config = lib.mkMerge [
    {
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

      local.llm.defaultModel = "zai/glm-5.2";
    }
    (lib.mkIf cc.enable {
      environment.sessionVariables = {
        ANTHROPIC_BASE_URL = ccProvider.anthropicUrl or ccProvider.url;
      };

      assertions = [
        {
          assertion = ccProvider ? tokenFile;
          message = "Claude Code provider '${cc.provider}' must have a tokenFile";
        }
      ];
    })
  ];
}
