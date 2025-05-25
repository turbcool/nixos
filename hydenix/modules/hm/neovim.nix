{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      ripgrep
      fd
      csharp-ls
      netcoredbg
    ];
  };
}
