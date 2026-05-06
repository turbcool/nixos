{ lib, osConfig, ... }:
{
  config.home.file.".config/opencode/opencode.json" = lib.mkForce {
    text = builtins.toJSON osConfig.local.llm.opencodeJson;
  };
}
