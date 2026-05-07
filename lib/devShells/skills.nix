{ pkgs, inputs }:

let
  agentLib = import "${inputs.agent-skills}/lib" {
    lib = pkgs.lib;
    inherit inputs;
  };

  rawConfig = import ../../config/skills.nix;
  groups = rawConfig.groups or { };
  sources = builtins.removeAttrs rawConfig [ "groups" ];
  sourceNames = builtins.attrNames sources;

  catalog = agentLib.discoverCatalog sources;

  mkSkillsShell =
    sourceList:
    let
      bundle = agentLib.mkBundle {
        inherit pkgs;
        selection = agentLib.selectSkills {
          inherit catalog sources;
          allowlist = agentLib.allowlistFor {
            inherit catalog sources;
            enableAll = sourceList;
          };
          skills = { };
        };
      };
    in
    pkgs.mkShellNoCC {
      shellHook = agentLib.mkShellHook {
        inherit pkgs bundle;
        targets.opencode = {
          dest = ".opencode/skills";
          structure = "copy-tree";
          enable = true;
        };
      };
    };

  groupShells = builtins.mapAttrs (_: mkSkillsShell) groups;

  individualShells = builtins.listToAttrs (
    builtins.map (name: {
      inherit name;
      value = mkSkillsShell [ name ];
    }) sourceNames
  );
in
{
  devShell = mkSkillsShell sourceNames;

  shells = groupShells // individualShells;
}
