{
  lib,
  pkgs,
  config,
  ...
} :

{
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
  };

  home.activation.work-pc = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.local/share/remmina"

    # Copy your base config
    cp ${./remmina/work-pc.remmina} "$HOME/.local/share/remmina/work-pc.remmina"

    # Substitute empty password line
    sed -i "s/^password=.*$/password=$(cat ${config.age.secrets.work-pc.path})/" \
      "$HOME/.local/share/remmina/work-pc.remmina"
  '';
}
