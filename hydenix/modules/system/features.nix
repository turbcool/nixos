{ lib, ... }:

{
  options.local.features = {
    browsers.enable = (lib.mkEnableOption "browser modules") // {
      default = true;
    };

    gaming.enable = (lib.mkEnableOption "gaming modules") // {
      default = true;
    };

    gaming.vr.enable = lib.mkEnableOption "VR gaming support";

    work.enable = (lib.mkEnableOption "work modules") // {
      default = true;
    };

    work.syncthing.enable = lib.mkEnableOption "Syncthing work profile";
  };
}
