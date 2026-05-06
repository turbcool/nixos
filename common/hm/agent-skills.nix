{ inputs, osConfig, lib, ... }:

let
  username = osConfig.local.profile.username;
in
{
  imports = [ inputs.agent-skills.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;

    sources = import ../../config/skills.nix;

    skills.enableAll = true;

    targets = { };
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
