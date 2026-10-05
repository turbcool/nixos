# Skills that ship with the agent runtime.
#
# Host-only skills are declared in /etc/nixos/config/skills.nix and merged in
# by common/hm/agent-skills.nix — `programs.agent-skills.sources` is a plain
# attrsOf, so both modules contribute to one source set, one bundle and one
# sync, rather than fighting over them.
#
# On NixOS this module only declares the sources; agent-skills' own activation
# links the trees into $HOME. For the standalone container config there is no
# activation to run, so the already-filtered per-target bundles are registered
# in `agent.runtimeFiles` and end up in the `agent-runtime-config` package for
# a container image to COPY into place.
{
  config,
  inputs,
  lib,
  ...
}:

let
  cfg = config.agent;
  skillConfig = import ../data/skills.nix;

  # `.agents/skills` is the cross-vendor convention that agents other than
  # opencode/claude read; it costs one symlink tree and means a new agent picks
  # the skills up without another entry here.
  enabledTargets = [
    "agents"
    "claude"
    "opencode"
  ];

  # agent-skills resolves these at activation time from $HOME, so the bundle
  # path has to match its own target dests.
  targetDest = {
    agents = ".agents/skills";
    claude = ".claude/skills";
    opencode = ".config/opencode/skills";
  };
in
{
  # The ONLY import of the agent-skills Home Manager module in this repo.
  # It is a Nix function rather than a path, so NixOS' collectImports cannot
  # dedupe it by location — importing it from a host module as well makes
  # every programs.agent-skills.* option fail with "already declared".
  # Modules that add host-specific sources must therefore only extend
  # `programs.agent-skills.sources`, never re-import the machinery.
  imports = [ inputs.agent-skills.homeManagerModules.default ];

  config = lib.mkIf cfg.skills.enable {
    programs.agent-skills = {
      enable = true;
      sources = skillConfig;
      skills.enableAll = true;
      targets = lib.genAttrs enabledTargets (_: {
        enable = true;
      });
    };

    agent.runtimeFiles =
      lib.mapAttrs'
        (name: path: {
          name = targetDest.${name};
          value = path;
        })
        (
          lib.filterAttrs (
            name: _: lib.elem name enabledTargets
          ) config.programs.agent-skills.targetBundlePaths
        );
  };
}
