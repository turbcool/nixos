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
    nvim_dir="${config.home.homeDirectory}/.config/nvim"

    if [ -d "$nvim_dir/.git" ]; then
      cd "$nvim_dir"
      ${git} remote set-url origin https://github.com/turbcool/nvim.git
      if ! ${git} pull --ff-only; then
        cd /
        rm -rf "$nvim_dir"
        ${git} clone https://github.com/turbcool/nvim.git "$nvim_dir"
      fi
    else
      rm -rf "$nvim_dir"
      ${git} clone https://github.com/turbcool/nvim.git "$nvim_dir"
    fi

    cd "$nvim_dir"
    ${git} remote set-url origin git@github.com:turbcool/nvim.git
  '';
}
