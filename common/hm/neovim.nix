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
      wget
      unzip
    ];
  };

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.activation.nvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "/home/turb/.config/nvim/.git" ]; then
      cd /home/turb/.config/nvim && ${git} remote set-url origin https://github.com/turbcool/nvim.git
      cd /home/turb/.config/nvim && ${git} pull --ff-only
    else
      ${git} clone https://github.com/turbcool/nvim.git /home/turb/.config/nvim
    fi
    cd /home/turb/.config/nvim && ${git} remote set-url origin git@github.com:turbcool/nvim.git
  '';
}
