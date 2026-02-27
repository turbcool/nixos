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
  ];

  programs.npm.enable = true;
}
