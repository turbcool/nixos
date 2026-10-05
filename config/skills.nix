# Host-only skills.
#
# Anything that should also run in the agent-runtime containers lives in
# agent-runtime/data/skills.nix instead — `programs.agent-skills.sources` is a
# plain attrsOf, so both modules contribute to one source set and one bundle.
# Keep this list to skills that genuinely need the desktop host (orca's
# server/client pairing, a browser, a local vault).
{
  orca = {
    input = "orca-skills";
    subdir = "skills";
  };
}
