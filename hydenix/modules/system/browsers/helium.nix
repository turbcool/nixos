# Helium browser - Chromium-based, privacy-first browser
{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.local.features.browsers;
in

{
  imports = [
    inputs.helium.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    programs.helium = {
      enable = true;
    };
  };
}
