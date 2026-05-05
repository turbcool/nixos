{ config, lib, ... }:

let
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
    provider.flexberry = {
      name = "flexberry";
      npm = "@ai-sdk/openai-compatible";
      models."qwen3-coder-128k:30b" = {
        name = "Qwen3-Coder-Next";
        family = "qwen";
        tool_call = true;
        reasoning = false;
        modalities = {
          input = [ "text" ];
          output = [ "text" ];
        };
        temperature = true;
        release_date = "2026-02-03";
        limit = {
          context = 128000;
          output = 32000;
        };
      };
      options = {
        baseURL = "{env:OPENAI_BASE_URL}";
        apiKey = "{env:OPENAI_TOKEN}";
      };
    };
    model = "qwen3-coder-128k:30b";
    small_model = "qwen3-coder-128k:30b";
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

  config.home.file = {
    ".config/opencode/opencode.json" = lib.mkForce {
      text = builtins.toJSON opencodeConfig;
    };
    ".config/opencode/oh-my-opencode.json" = lib.mkForce {
      source = ./config/oh-my-opencode.json;
    };
  };
}
