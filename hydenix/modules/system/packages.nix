# Package definitions and program configurations
{ config, pkgs, ... }:

let
  tsSql = pkgs.tree-sitter.withPlugins (p: [ p.tree-sitter-sql ]);
in {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pkgs.telegram-desktop
    pkgs.userPkgs.aider-chat # Using unstable package defined in configuration.nix
    pkgs.userPkgs.yazi
    pkgs.yt-dlp

    # Work:
    pkgs.zoom-us
    pkgs.remmina
    pkgs.networkmanager-l2tp
    pkgs.onlyoffice-bin
    #(pkgs.harlequin.override {
    #  withBigQueryAdapter = false;
    #})
    #tsSql
    
    # Organize:
    pkgs.neomutt 

    # Security:
    pkgs.bitwarden-cli
  ];

  programs.npm.enable = true;
}
