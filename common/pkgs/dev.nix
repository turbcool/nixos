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
    gitlab-ci-local
    (python312.withPackages (ps: with ps; [ pip ]))
  ];

  programs.npm.enable = true;
}
