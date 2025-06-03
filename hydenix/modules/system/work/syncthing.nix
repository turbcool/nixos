{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      gui = {
        user = "turb";
        password = "syncthing";
      };
      devices = {
        "kris-notebook" = { id = "6GMRU5U-EQWZTTM-6STQ5V7-YI4CTHA-PB3CUZM-A6YD5PB-2B7EJNA-XJRWVQO"; };
      };
      folders = {
        "Кристина_Гугл_Диск" = {         # Name of folder in Syncthing, also the folder ID
          path = "/mnt/windows_old/Кристина_Гугл_Диск";    # Which folder to add to Syncthing
          devices = [ "kris-notebook" ];      # Which devices to share the folder with
        };
      };
    };
  };
}
