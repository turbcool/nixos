# Extra modules for the standalone `homeConfigurations.agent-runtime` — the
# container/Home-Manager-standalone flavour. Never imported by the NixOS hosts.
#
# The only real difference from a desktop login is the home directory: there is
# no local.profile here, so pick a plain root-ish one. Everything else (pi,
# opencode, the claude wrappers) is identical to the host, which is the point.
{
  lib,
  ...
}:

{
  home = {
    username = lib.mkDefault "root";
    homeDirectory = lib.mkDefault "/root";
    stateVersion = lib.mkDefault "25.05";
    sessionPath = [
      "$HOME/.npm/bin"
      "$HOME/.local/bin"
    ];
  };

  # No desktop shell: the container is entered with `nix develop` / a plain
  # exec, so drop interactive-extras and keep the bundle headless.
  agent.agents.includeTui = false;
}
