{ config, lib, ... }:

let
  workCfg = config.local.features.work;
  syncthingCfg = config.local.features.work.syncthing;
  username = config.local.profile.username;
in

{
  config = lib.mkIf (workCfg.enable && syncthingCfg.enable) {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        gui = {
          user = username;
          password = "syncthing";
        };
        devices = {
          "kris-notebook" = { id = "6GMRU5U-EQWZTTM-6STQ5V7-YI4CTHA-PB3CUZM-A6YD5PB-2B7EJNA-XJRWVQO"; };
        };
        folders = {
          "Кристина_Гугл_Диск" = {
            path = "/mnt/windows_old/Кристина_Гугл_Диск";
            devices = [ "kris-notebook" ];
          };
        };
      };
    };
  };
}
