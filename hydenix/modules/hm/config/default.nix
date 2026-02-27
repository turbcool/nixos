{
  lib,
  pkgs,
  config,
  ...
} :

let
  git = "${pkgs.git}/bin/git";
in {
  age.secrets.work-pc = {
    file = ../../../secrets/work-pc.age;
  };

  home.file = {
    ".ssh/config" = lib.mkForce {
      source = ./ssh-config.txt;
    };

    ".local/share/remmina/autocam.remmina" = lib.mkForce {
      source = ./remmina/autocam.remmina;
      force = true;
    };
    ".local/share/toggle-sidepad.sh" = {
      source = ./hyprland/toggle-sidepad.sh;
      force = true;
    };
    "/build.sh" = lib.mkForce {
      source = ./build.sh;
      force = true;
    };
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/turb/nvim";
    };
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

  home.activation.work-pc = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.local/share/remmina"

    # Copy your base config
    cp ${./remmina/work-pc.remmina} "$HOME/.local/share/remmina/work-pc.remmina"

    # Substitute empty password line
    sed -i "s/^password=.*$/password=$(cat ${config.age.secrets.work-pc.path})/" \
      "$HOME/.local/share/remmina/work-pc.remmina"
  '';
}
