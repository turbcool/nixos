{ pkgs }:

let
  raw = import ../../config/mcp.nix { inherit pkgs; };
  groups = raw.groups or { };
  servers = builtins.removeAttrs raw [ "groups" ];
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
