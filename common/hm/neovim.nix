{
  lib,
  pkgs,
  config,
  ...
}:

let
  git = "${pkgs.git}/bin/git";
in
{
  programs.neovim = {
    enable = true;

    # The nvim config is a git checkout of turbcool/nvim, cloned/pulled by
    # home.activation.nvim below, so HM must not write into that directory.
    # programs.neovim's plugin machinery auto-fills initLua with the advised
    # plugin config, and the `mkIf (initLua != "")` guard then makes HM own
    # ~/.config/nvim/init.lua. The activation runs after writeBoundary and
    # replaces that symlink with the repo's real file, so the *next*
    # activation aborts with
    #   "Existing file '~/.config/nvim/init.lua' would be clobbered".
    # Forcing initLua to "" makes the file vanish from the config entirely
    # (and sideloadInitLua stays a no-op). HM's only remaining job here is
    # the package set: extraPackages under XDG_DATA_HOME, plus the binary.
    initLua = lib.mkForce "";

    extraPackages = with pkgs; [
      csharp-ls
    ];
  };

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
