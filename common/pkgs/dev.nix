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
    nmap
    dnsutils
    starship
    gitlab-ci-local
  ];

  programs.npm.enable = true;
}
