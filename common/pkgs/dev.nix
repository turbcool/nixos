{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodejs
    lazygit
    lazydocker
    ripgrep
    gdu
    gcc
    yazi
    postgresql_17
    zotero
    nmap
    dnsutils
    starship
  ];

  programs.npm.enable = true;
}
