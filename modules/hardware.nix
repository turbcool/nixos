# Hardware-specific settings
{ config, pkgs, ... }:

{
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };
  };
  services.xserver.videoDrivers = ["nvidia"];
}
