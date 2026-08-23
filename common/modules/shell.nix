{ inputs, pkgs, ... }:

let
  cli = import ../../lib/scripts/cli.nix { inherit pkgs; };
in
{
  programs.zsh.enable = true;

  environment.systemPackages = [
    cli.mcp
  ];
}
