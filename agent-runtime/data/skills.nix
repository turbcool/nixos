# Skills that ship with the agent runtime — injected everywhere it runs, i.e.
# both NixOS hosts and the standalone agent-runtime containers.
#
# Format is agent-skills' source registry. `input` names an entry in the
# *consuming* flake's inputs: /etc/nixos wires agent-runtime's inputs to follow
# its own (see its flake.nix) and declares these same names, so this file
# resolves identically under both flakes.
#
# Host-only skills (orca, playwright-cli) stay in /etc/nixos/config/skills.nix.
{
  adhd = {
    input = "i-have-adhd";
    subdir = "skills";
  };

  archify = {
    input = "archify";
    subdir = "archify";
  };

  # The archify repo keeps a second skill outside archify/ — without this entry
  # only the diagram generator gets injected, not the review/triage workflow.
  archify-review = {
    input = "archify";
    subdir = ".agents/skills";
  };

  # Also loaded as an opencode plugin (agent-runtime/modules/home.nix).
  ponytail = {
    input = "ponytail";
    subdir = "skills";
  };

  # qmd ships a maintainer-facing `release` skill next to the useful one.
  qmd = {
    input = "qmd";
    subdir = "skills";
    filter.nameRegex = "^qmd$";
  };
}
