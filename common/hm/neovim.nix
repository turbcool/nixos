{ lib, pkgs, config, ... }:

let
  git = "${pkgs.git}/bin/git";
in
{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      ripgrep
      fd
      csharp-ls
      netcoredbg
      omnisharp-roslyn
      wget
      unzip
    ];
  };

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/turb/nvim";
  };

  home.activation.nvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "/home/turb/nvim/.git" ]; then
      cd /home/turb/nvim && ${git} remote set-url origin https://github.com/turbcool/nvim.git
      cd /home/turb/nvim && ${git} pull --ff-only
    else
      ${git} clone https://github.com/turbcool/nvim.git /home/turb/nvim
    fi
    cd /home/turb/nvim && ${git} remote set-url origin git@github.com:turbcool/nvim.git
  '';
}
