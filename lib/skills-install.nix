{ pkgs, inputs }:

let
  # Reuse agent-skills' local sync program (skills-install-local) instead of the
  # old devshell generator: it copies a selected skill bundle into .opencode/skills.
  agentLib = import "${inputs.agent-skills}/lib" {
    lib = pkgs.lib;
    inherit inputs;
  };

  # Note: ../ (one level) — this file lives in lib/, not lib/scripts/.
  # Host-only skills; the runtime's own skills are already installed globally by
  # agent-skills, so this only offers the per-project copies.
  sources = import ../config/skills.nix;

  catalog = agentLib.discoverCatalog sources;

  mkInstall =
    name:
    agentLib.mkLocalInstallProgram {
      inherit pkgs;
      bundle = agentLib.mkBundle {
        inherit pkgs;
        selection = agentLib.selectSkills {
          inherit catalog sources;
          allowlist = agentLib.allowlistFor {
            inherit catalog sources;
            enableAll = [ name ];
          };
          skills = { };
        };
      };
      targets.opencode = {
        enable = true;
        dest = ".opencode/skills";
        structure = "copy-tree";
      };
    };
in
{
  installs = builtins.mapAttrs (name: _: mkInstall name) sources;
}
