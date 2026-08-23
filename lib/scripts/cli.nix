{ pkgs }:

let
  mcpConfig = import ../../config/mcp.nix { inherit pkgs; };

  mcpGroups = mcpConfig.groups or { };
  mcpServers = builtins.removeAttrs mcpConfig [ "groups" ];

  allMcpNames = (builtins.attrNames mcpServers) ++ (builtins.attrNames mcpGroups);

  mkList = items: builtins.concatStringsSep "\n" items;

  mcpHelp = mkList (
    [ "Groups:" ]
    ++ (builtins.attrValues (
      builtins.mapAttrs (name: srvs: "  ${name} → ${builtins.concatStringsSep ", " srvs}") mcpGroups
    ))
    ++ [
      ""
      "Servers:"
    ]
    ++ (builtins.map (name: "  ${name}") (builtins.attrNames mcpServers))
  );

  flake = "/etc/nixos";
in
{
  mcp = pkgs.writeShellScriptBin "mcp" ''
    if [ $# -eq 0 ]; then
      echo "Usage: mcp <group|server>"
      echo ""
      echo "${mcpHelp}"
      exit 0
    fi

    name="$1"

    case "$name" in
      ${builtins.concatStringsSep "|" allMcpNames})
        ;;
      *)
        echo "✗ Unknown MCP group or server: $name"
        echo ""
        echo "${mcpHelp}"
        exit 1
        ;;
    esac

    config="$(${pkgs.coreutils}/bin/realpath "$(
      nix build "${flake}#mcp-config-$name" --no-link --print-out-paths 2>/dev/null
    )")"

    if [ ! -f "$config" ]; then
      echo "✗ Failed to build MCP config for: $name"
      exit 1
    fi

    if [ -f opencode.json ]; then
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' opencode.json "$config" > opencode.json.tmp \
        && mv opencode.json.tmp opencode.json
    else
      cp "$config" opencode.json
    fi
    echo "✓ MCP servers activated: $name"
  '';
}
