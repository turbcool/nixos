{ config, lib, ... }:

let
  cfg = config.local.features.gaming;
in

{
  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extest.enable = true; # Steam Input on Wayland
    };
  };
}
