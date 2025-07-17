{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      ripgrep
      fd
      csharp-ls
      unzip # for mason installs
      netcoredbg
      omnisharp-roslyn
    ];
  };
}
