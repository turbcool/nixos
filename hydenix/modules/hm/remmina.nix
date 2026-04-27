{ config, lib, ... }:

{
  age.secrets.work-pc = {
    file = ../../secrets/work-pc.age;
  };

  home.file = {
    ".local/share/remmina/autocam.remmina" = lib.mkForce {
      source = ./remmina/autocam.remmina;
      force = true;
    };
  };

  home.activation.work-pc = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.local/share/remmina"

    cp ${./remmina/work-pc.remmina} "$HOME/.local/share/remmina/work-pc.remmina"

    sed -i "s/^password=.*$/password=$(cat ${config.age.secrets.work-pc.path})/" \
      "$HOME/.local/share/remmina/work-pc.remmina"
  '';
}
