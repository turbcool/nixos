{ config, lib, osConfig, ... }:

let
  llm = osConfig.local.llm;

  opencodeConfig = {
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
    provider = llm.opencodeProviders;
  } // lib.optionalAttrs (llm.defaultModel != null) {
    model = llm.defaultModel;
    small_model = llm.smallModel;
  } // {
    mcp = {
      nixos = {
        type = "local";
        command = [ "mcp-nixos" ];
        enabled = true;
      };
      daisyui = {
        type = "local";
        command = [ "docker" "run" "-i" "--rm" "daisyui-mcp" ];
        enabled = true;
      };
    } // config.local.opencode.extraMcp;
  };
in
{
  options.local.opencode.extraMcp = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
    description = "Additional OpenCode MCP server definitions to merge into the managed opencode config.";
  };

  config.home.file.".config/opencode/opencode.json" = lib.mkForce {
    text = builtins.toJSON opencodeConfig;
  };
}
