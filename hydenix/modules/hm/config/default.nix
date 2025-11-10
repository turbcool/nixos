{
  lib,
  pkgs,
  config,
  ...
}

: {
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
    "/build.sh" = lib.mkForce {
      source = ./build.sh;
      force = true;
    };
    ".config/nvim" = {
      source = pkgs.fetchFromGitHub {
        owner = "turbcool";
        repo = "nvim";
        rev = "64164a15cd6bcdaa83a17f0ea6169c6daa1686ea";
        hash = "sha256-kYb3zgsWY7xQ3u1UsbpwCd9XW34Q23iRAThUBjVtyaA=";
      };
    };
    ".config/mihomo/config.yaml" = lib.mkForce {
      source = ./mihomo/config.yaml;
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
