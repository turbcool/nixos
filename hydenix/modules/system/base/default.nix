{ ... }:

{
  imports = [
    ./boot.nix
    ./desktop.nix
    ./networking.nix
    ./printing.nix
    ./user.nix
  ];

  services.journald = {
    extraConfig = ''
      SystemMaxUse=1G
      SystemKeepFree=1G
    '';
  };
}
