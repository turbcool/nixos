# Host-only skills (config/skills.nix), merged with the ones the agent runtime
# ships (agent-runtime/data/skills.nix).
#
# Both contribute entries to `programs.agent-skills.sources`, so the result is
# one source set → one catalog → one bundle → one sync per target.
#
# This module deliberately does NOT import agent-skills' Home Manager module:
# agent-runtime/modules/skills.nix already does, and importing a Nix function
# module twice makes every programs.agent-skills.* option collide. It is
# therefore only importable alongside the agent runtime (agent.skills.enable
# must stay on).
{
  lib,
  ...
}:

let
  skillConfig = import ../../config/skills.nix;
  # `groups` is a CLI-only concept; the HM `sources` option can't parse it.
  skillSources = builtins.removeAttrs skillConfig [ "groups" ];
in
{
  programs.agent-skills = {
    enable = true;

    sources = skillSources;

    skills.enableAll = true;

    targets.opencode.enable = true;
    targets.claude.enable = true;
  };
}
