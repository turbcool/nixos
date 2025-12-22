{ ... }:

{
  imports = [
    ./boot.nix
    ./desktop.nix
    ./git.nix
    ./networking.nix
    ./printing.nix
    ./user.nix
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    WEATHER_LOCATION = "Perm";
  };

  services.journald = {
    extraConfig = ''
      SystemMaxUse=1G
      SystemKeepFree=1G
    '';
  };
}
