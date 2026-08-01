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
  ccBaseUrl = ccProvider.anthropicUrl or ccProvider.url;

  pluginsConfig = import ../../config/plugins.nix;

  managedSettings = builtins.toJSON (
    {
      # Only host-agnostic Claude Code knobs live here. Managed settings take the
      # highest precedence and cannot be overridden, so anything provider-specific
      # (ANTHROPIC_BASE_URL, the ANTHROPIC_DEFAULT_*_MODEL tier map) must NOT be
      # set here — otherwise paseo's per-provider profiles (see wsl/paseo.nix)
      # couldn't repoint Claude Code at a different endpoint. Interactive `claude`
      # still gets those via the .zshrc exports in common/hm/claude-code.nix.
      env = {
        CLAUDE_CODE_SUBAGENT_MODEL = cc.models.subagent;
        CLAUDE_CODE_AUTO_COMPACT_WINDOW = "1000000";
      };
    }
    // (lib.optionalAttrs (pluginsConfig.marketplaces != { }) {
      extraKnownMarketplaces = pluginsConfig.marketplaces;
    })
    // (lib.optionalAttrs (pluginsConfig.plugins != { }) {
      enabledPlugins = pluginsConfig.plugins;
    })
  );
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
        default = "free";
      };

      models = {
        opus = lib.mkOption {
          type = lib.types.str;
          default = "deepseek-zen-free";
        };
        sonnet = lib.mkOption {
          type = lib.types.str;
          default = "deepseek-zen-free";
        };
        haiku = lib.mkOption {
          type = lib.types.str;
          default = "deepseek-zen-free";
        };
        subagent = lib.mkOption {
          type = lib.types.str;
          default = "deepseek-zen-free";
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

      local.llm.defaultModel = "free/deepseek-zen-free";
      local.llm.smallModel = "free/deepseek-zen-free";
    }
    (lib.mkIf cc.enable {
      environment.sessionVariables = {
        ANTHROPIC_BASE_URL = ccProvider.anthropicUrl or ccProvider.url;
      };

      # Declarative, immutable Claude Code config. Managed settings take the
      # highest precedence and cannot be overridden, freeing the user-scope
      # ~/.claude/settings.json to be a writable file that Claude's plugin
      # install flow can write to.
      environment.etc."claude-code/managed-settings.json".text = managedSettings;

      assertions = [
        {
          assertion = ccProvider ? tokenFile;
          message = "Claude Code provider '${cc.provider}' must have a tokenFile";
        }
      ];
    })
  ];
}
