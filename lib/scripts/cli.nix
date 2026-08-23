{ pkgs, inputs }:

let
  mcpConfig = import ../../config/mcp.nix { inherit pkgs; };
  skillsConfig = import ../../config/skills.nix;

  mcpGroups = mcpConfig.groups or { };
  mcpServers = builtins.removeAttrs mcpConfig [ "groups" ];
  allMcpNames = (builtins.attrNames mcpServers) ++ (builtins.attrNames mcpGroups);

  skillsSources = builtins.attrNames (builtins.removeAttrs skillsConfig [ "groups" ]);
  skillsGroups = skillsConfig.groups or { };
  allSkillsNames = skillsSources ++ (builtins.attrNames skillsGroups);

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

  skillsHelp = mkList (
    [ "Groups:" ]
    ++ (builtins.attrValues (
      builtins.mapAttrs (name: srcs: "  ${name} → ${builtins.concatStringsSep ", " srcs}") skillsGroups
    ))
    ++ [
      ""
      "Sources:"
    ]
    ++ (builtins.map (name: "  ${name}") skillsSources)
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

  skills = pkgs.writeShellScriptBin "skills" ''
    # On-demand per-project install: build the skills-install-<name> package
    # (a copy-tree bundle, see lib/skills-install.nix) and run its installer.
    if [ $# -eq 0 ]; then
      echo "Usage: skills <group|source>"
      echo ""
      echo "${skillsHelp}"
      exit 0
    fi

    name="$1"

    case "$name" in
      ${builtins.concatStringsSep "|" allSkillsNames})
        ;;
      *)
        echo "✗ Unknown skill group or source: $name"
        echo ""
        echo "${skillsHelp}"
        exit 1
        ;;
    esac

    program="$(${pkgs.coreutils}/bin/realpath "$(
      nix build "${flake}#skills-install-$name" --no-link --print-out-paths 2>/dev/null
    )")"

    if [ ! -x "$program/bin/skills-install-local" ]; then
      echo "✗ Failed to build skill installer for: $name"
      exit 1
    fi

    ( cd . && "$program/bin/skills-install-local" )
    echo "✓ Skills installed to .opencode/skills: $name"
  '';
}
