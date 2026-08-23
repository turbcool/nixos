{ inputs, osConfig, lib, ... }:

let
  username = osConfig.local.profile.username;
  skillConfig = import ../../config/skills.nix;
  skillSources = builtins.removeAttrs skillConfig [ "groups" ];
in
{
  imports = [ inputs.agent-skills.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;

    sources = skillSources;

    skills.enableAll = true;

    targets.opencode.enable = true;
  };

  home.file.".obsidian-wiki/config".text = ''
    OBSIDIAN_VAULT_PATH=/home/${username}/repos/obsidian-wiki-vault
    OBSIDIAN_WIKI_REPO=${inputs.obsidian-wiki}
  '';

  home.activation.create-obsidian-vault =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/repos/obsidian-wiki-vault"
    '';
}
