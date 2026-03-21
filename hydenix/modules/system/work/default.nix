{ pkgs, ... }:

{
  imports = [
    ./l2tp.nix
    #./syncthing.nix
    ./virt.nix
    ./work.nix
  ];
}
