{ ... }:

{
  imports = [
    ./development.nix
    ./dotnet.nix
    ./l2tp.nix
    ./llm-cli.nix
    ./syncthing.nix
    ./virt.nix
    ./work.nix
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    WEATHER_LOCATION = "Perm";
  };
}
