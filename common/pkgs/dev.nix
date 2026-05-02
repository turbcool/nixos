{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodejs
    mcp-nixos
    lazygit
    lazydocker
    ripgrep
    gdu
    gcc
    yazi
    postgresql_17
    nmap
    dnsutils
    gitlab-ci-local
  ];

  programs.npm.enable = true;
}
