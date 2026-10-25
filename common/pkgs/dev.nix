{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.pkgs.dev;
in
{
  options.local.pkgs.dev.enable = (lib.mkEnableOption "development packages") // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    # `mcp-nixos`, the two npm MCP servers, programs.npm and programs.nix-ld are
    # all owned by the agent-runtime module now (derived from the registry it
    # ships), so they are not declared here.
    # nodejs arrives from the runtime's programs.npm on every host; gcc is
    # nixarchy base (`languageServer`), so wsl declares its own.
    environment.systemPackages = with pkgs; [
      gitlab-ci-local
      uv
    ];
  };
}
