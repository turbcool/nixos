{ pkgs, ... }:

{
  imports = [
    ./base/default.nix
    ./browsers/default.nix
    ./gaming/default.nix
    ./work/default.nix
  ];

  environment.systemPackages = with pkgs; [
    pkgs.kdePackages.ark
    pkgs.easyeffects
    pkgs.qbittorrent-enhanced
    pkgs.lowfi
    (python3.withPackages (python-pkgs: with python-pkgs; [
      uv
    ]))
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    WEATHER_LOCATION = "Perm";
  };
}
