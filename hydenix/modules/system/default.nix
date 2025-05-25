{ ... }:

{
  imports = [
    ./base/boot.nix
    ./base/desktop.nix
    ./base/networking.nix
    ./base/user.nix
    ./packages.nix
    ./virt.nix
    ./browsers/brave.nix
    ./gaming.nix
    ./nvim.nix
    # ./example.nix - add your modules here
  ];

  environment.systemPackages = [
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
}
