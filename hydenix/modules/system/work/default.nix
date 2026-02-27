{ pkgs, ... }:

{
  imports = [
    ./development.nix
    ./dotnet.nix
    ./l2tp.nix
    ./syncthing.nix
    ./virt.nix
    ./work.nix
  ];
}
