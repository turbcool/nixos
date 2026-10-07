# Host-only skills. Resolved against the host flake's `inputs` by
# `common/modules/agent.nix` (`import ../../config/skills.nix inputs`), so it
# is a function of `inputs`, not a free-variable reference.
{ inputs }: {
  orca = {
    path = "${inputs.orca-skills}/skills";
  };
}
