{ ... }:

{
  imports = [
    ./base/boot.nix
    ./base/desktop.nix
    ./base/networking.nix
    ./base/user.nix
    ./browsers/brave.nix
    ./work/development.nix
    ./work/syncthing.nix
    ./work/virt.nix
    ./work/work.nix
    ./gaming.nix
    ./packages.nix
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
}
