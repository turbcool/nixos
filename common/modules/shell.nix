{ inputs, pkgs, ... }:

let
  cli = import ../../lib/scripts/cli.nix { inherit pkgs; };
  # The MCP toggle ships with the agent runtime: it renders that flake's
  # registry (data/mcp.nix), which lives there too.
  mcp = inputs.agent-runtime.packages.${pkgs.stdenv.hostPlatform.system}.mcp;
in
{
  programs.zsh.enable = true;

  environment.systemPackages = [
    cli.skills
    mcp
  ];
}
