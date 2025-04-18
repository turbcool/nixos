{ ... }:

{
  imports = [
    ./core.nix
    ./desktop.nix
    ./networking.nix
    ./packages.nix
    ./user.nix
    # ./example.nix - add your modules here
  ];

  environment.systemPackages = [
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];
}
