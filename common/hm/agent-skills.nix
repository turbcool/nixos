{ inputs, osConfig, lib, ... }:

let
  username = osConfig.local.profile.username;
in
{
  imports = [ inputs.agent-skills.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;

    sources = {
      obsidian-wiki = {
        input = "obsidian-wiki";
        subdir = ".skills";
      };
      kepano-obsidian = {
        input = "kepano-obsidian-skills";
        subdir = "skills";
      };
    };

    skills.enableAll = true;

    targets = {
      opencode.enable = true;
      agents.enable = true;
    };
  };

  home.file.".obsidian-wiki/config".text = ''
    OBSIDIAN_VAULT_PATH=/home/${username}/obsidian-vault
    OBSIDIAN_WIKI_REPO=${inputs.obsidian-wiki}
  '';

  home.activation.create-obsidian-vault =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/obsidian-vault"
    '';
}
