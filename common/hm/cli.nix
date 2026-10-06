{
  lib,
  pkgs,
  ...
}:

# Shell/tooling setup only. The claude/opencode/pi binaries, their config and
# the provider-pinned commands live in the agent-runtime flake (see
# agent-runtime/modules).
{
  home = {
    packages = [ pkgs.yt-dlp ];

    # $HOME/.npm/bin (where programs.npm puts the global npm packages, and
    # where the MCP servers live) comes from agent.npmPrefix in the runtime
    # module. Requires programs.nix-ld (common/modules/nix-ld.nix) so prebuilt
    # glibc binaries (bladebro, donsetch) can run; the runtime's activation
    # hook reinstalls them when they go missing.
    sessionPath = [
      "$HOME/.dotnet/tools"
      "$HOME/.local/bin"
    ];
  };

  programs.zsh = {
    enable = true;
    history = {
      path = "$HOME/.histfile";
      size = 1000;
      save = 1000;
    };
    shellAliases = {
      build = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
      opencode-playwright = "nix develop /etc/nixos#opencode-playwright";
      proxy = "proxy-toggle";
    };
    initContent = ''
      proxy-toggle() {
        if [ -n "$http_proxy" ]; then
          unset http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
          echo "Proxy disabled"
        else
          if [ -z "''${PROXY_URL:-}" ]; then
            echo "PROXY_URL not set"
            return 1
          fi
          export http_proxy="$PROXY_URL"
          export https_proxy="$PROXY_URL"
          export HTTP_PROXY="$PROXY_URL"
          export HTTPS_PROXY="$PROXY_URL"
          export no_proxy="localhost,127.0.0.1"
          export NO_PROXY="localhost,127.0.0.1"
          echo "Proxy enabled: $PROXY_URL"
        fi
      }
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
