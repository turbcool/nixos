{ 
  lib,
  pkgs,
  config,
  ...
}:

{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      pkgs.dotnet-sdk_8
      pkgs.dotnet-runtime_8
      pkgs.dotnet-aspnetcore_8
      pkgs.roslyn-ls
    ];
  };
}
