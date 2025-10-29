{ config, pkgs, ... }:

let
  # Import agenix secrets
  secrets = config.age.secrets;
in
{
  imports = [
    ./remmina.nix
  ];

  # Agenix configuration
  age = {
    identityPaths = [ "/home/turb/.ssh/id_ed25519" ];
    secrets = {
      remmina-work-pc = {
        file = ./../../../../secrets/remmina-work-pc.age;
        path = "/home/turb/.config/remmina/remmina-work-pc-password";
        mode = "600";
        owner = "turb";
      };
      remmina-autocam = {
        file = ./../../../../secrets/remmina-autocam.age;
        path = "/home/turb/.config/remmina/remmina-autocam-password";
        mode = "600";
        owner = "turb";
      };
      vpn-password = {
        file = ./../../../../secrets/vpn-password.age;
        path = "/home/turb/.config/vpn-password";
        mode = "600";
        owner = "turb";
      };
    };
  };
}