{ pkgs, inputs }:

let
  # data/ lives in the agent-runtime flake; + "/…" addresses its store path.
  # `groups` and `npm` are reserved keys there, not servers.
  raw = import (inputs.agent-runtime + "/data/mcp.nix");
  groups = raw.groups or { };
  servers = builtins.removeAttrs raw [ "groups" "npm" ];
  serverNames = builtins.attrNames servers;

  mkMcpConfig =
    serverNames':
    let
      selected = builtins.listToAttrs (
        builtins.map (name: {
          inherit name;
          value = servers.${name};
        }) serverNames'
      );
    in
    pkgs.writeText "opencode-mcp.json" (builtins.toJSON { mcp = selected; });

  allConfigs =
    groups
    // (builtins.listToAttrs (
      builtins.map (name: {
        inherit name;
        value = [ name ];
      }) serverNames
    ));
in
{
  configs = builtins.mapAttrs (_: mkMcpConfig) allConfigs;
}
