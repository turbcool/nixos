{ pkgs, inputs }:

let
  # Reuse agent-skills' local sync program (skills-install-local) instead of the
  # old devshell generator: it copies a selected skill bundle into .opencode/skills.
  agentLib = import "${inputs.agent-skills}/lib" {
    lib = pkgs.lib;
    inherit inputs;
  };

  # Note: ../ (one level) — this file lives in lib/, not lib/scripts/.
  rawConfig = import ../config/skills.nix;
  groups = rawConfig.groups or { };
  sources = builtins.removeAttrs rawConfig [ "groups" ];
  sourceNames = builtins.attrNames sources;

  catalog = agentLib.discoverCatalog sources;

  mkInstall =
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
    agentLib.mkLocalInstallProgram {
      inherit pkgs bundle;
      targets.opencode = {
        enable = true;
        dest = ".opencode/skills";
        structure = "copy-tree";
      };
    };
in
{
  names = sourceNames ++ (builtins.attrNames groups);

  installs =
    (builtins.listToAttrs (
      builtins.map (name: {
        inherit name;
        value = mkInstall [ name ];
      }) sourceNames
    ))
    // (builtins.mapAttrs (_: mkInstall) groups);
}
