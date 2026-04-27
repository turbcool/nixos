{ config, lib, ... }:

let
  gamingCfg = config.local.features.gaming;
  vrCfg = config.local.features.gaming.vr;
in

{
  config = lib.mkIf (gamingCfg.enable && vrCfg.enable) {
    programs.alvr.enable = true;
    programs.alvr.openFirewall = true;
  };
}
