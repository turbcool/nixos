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

  mkMcpShell =
    serverNames':
    pkgs.mkShellNoCC {
      OPENCODE_CONFIG = toString (mkMcpConfig serverNames');
    };

  groupShells = builtins.mapAttrs (_: serverNames': mkMcpShell serverNames') groups;

  individualShells = builtins.listToAttrs (
    builtins.map (name: {
      inherit name;
      value = mkMcpShell [ name ];
    }) serverNames
  );

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
  devShell = mkMcpShell serverNames;

  shells = groupShells // individualShells;

  configs = builtins.mapAttrs (_: mkMcpConfig) allConfigs;
}
