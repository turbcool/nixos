# Собирает бандл навыков из общих источников
# и отдаёт devShell, который через shellHook копирует их в .opencode/skills/.
# Использование в .envrc проекта: use flake /etc/nixos#skills
{ pkgs, inputs }:

let
  agentLib = import "${inputs.agent-skills}/lib" {
    lib = pkgs.lib;
    inherit inputs;
  };

  sources = import ../../config/skills.nix;

  catalog = agentLib.discoverCatalog sources;

  bundle = agentLib.mkBundle {
    inherit pkgs;
    selection = agentLib.selectSkills {
      inherit catalog sources;
      allowlist = agentLib.allowlistFor {
        inherit catalog sources;
        enableAll = true;
        enable = [ ];
      };
      skills = { };
    };
  };
in
{
  devShell = pkgs.mkShellNoCC {
    shellHook = agentLib.mkShellHook {
      inherit pkgs bundle;
      targets.opencode = {
        dest = ".opencode/skills";
        structure = "copy-tree";
        enable = true;
      };
    };
  };
}
