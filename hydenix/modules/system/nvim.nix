{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.nvim
    pkgs.vscode
    pkgs.nodejs
    pkgs.dotnet-sdk_8
    pkgs.unzip
    pkgs.omnisharp-roslyn
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.ripgrep
    pkgs.gdu
    pkgs.gcc
  ];
  // TODO: HM copy git to ~/.config/nvim
}
