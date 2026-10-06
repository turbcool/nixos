{ pkgs }:

let
  # Host-only skills (config/skills.nix). The runtime's own skills are installed
  # globally by agent-skills, so this CLI only needs the host list. The `mcp`
  # CLI, by contrast, ships with the agent runtime: it renders the very registry
  # the runtime owns.
  skillsSources = import ../../config/skills.nix;
  skillsNames = builtins.attrNames skillsSources;
  skillsUsage = ''
    Usage: skills <source>

    Sources:
    ${builtins.concatStringsSep "\n" (map (name: "  ${name}") skillsNames)}
  '';

  flake = "/etc/nixos";
in
{
  skills = pkgs.writeShellScriptBin "skills" ''
    # On-demand per-project install: build the skills-install-<name> package
    # (a copy-tree bundle, see lib/skills-install.nix) and run its installer.
    if [ $# -eq 0 ]; then
      echo "${skillsUsage}"
      exit 0
    fi

    name="$1"

    case "$name" in
    ${builtins.concatStringsSep "|" skillsNames})
      ;;
    *)
      echo "✗ Unknown skill source: $name"
      echo ""
      echo "${skillsUsage}"
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
