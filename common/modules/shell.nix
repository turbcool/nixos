{ inputs, pkgs, ... }:

let
  cli = import ../../lib/scripts/cli.nix { inherit pkgs inputs; };
in
{
  programs.zsh.enable = true;

  environment.systemPackages = [
    cli.skills
    cli.mcp
  ];
}
