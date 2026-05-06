{ lib, osConfig, ... }:

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
  };
in
{
  config.home.file.".config/opencode/opencode.json" = lib.mkForce {
    text = builtins.toJSON opencodeConfig;
  };
}
