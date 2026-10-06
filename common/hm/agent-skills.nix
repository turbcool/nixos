# Host-only skills (config/skills.nix), merged with the ones the agent runtime
# ships (agent-runtime/data/skills.nix).
#
# Both contribute entries to `programs.agent-skills.sources`, so the result is
# one source set → one catalog → one bundle → one sync per target. Everything
# else (enable, enableAll, the three targets) is the runtime's job, set in
# agent-runtime/modules/skills.nix.
#
# This module deliberately does NOT import agent-skills' Home Manager module:
# agent-runtime/modules/skills.nix already does, and importing a Nix function
# module twice makes every programs.agent-skills.* option collide. It is
# therefore only importable alongside the agent runtime.
{ ... }:

{
  programs.agent-skills.sources = import ../../config/skills.nix;
}
