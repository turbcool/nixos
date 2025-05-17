{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.neovim
    pkgs.vscode
    pkgs.nodejs
    pkgs.dotnet-sdk_8
    pkgs.dotnet-runtime_8
    pkgs.dotnet-aspnetcore_8
    pkgs.roslyn-ls
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.ripgrep
    pkgs.gdu
    pkgs.gcc
  ];
  # TODO: HM copy nvim config from git to ~/.config/nvim
}
