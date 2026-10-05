{
  lib,
  pkgs,
  ...
}:

# Shell/tooling setup only. The claude/opencode/pi binaries, their config and
# their wrappers live in the agent-runtime flake (see agent-runtime/modules).
{
  home = {
    packages = [ pkgs.yt-dlp ];

    # Global npm packages install into $HOME/.npm (set by programs.npm
    # `/etc/npmrc`, the NixOS-wiki home approach). Add its bin dir to PATH.
    # Requires programs.nix-ld (common/modules/nix-ld.nix) so prebuilt glibc
    # binaries (bladebro, donsetch) can run.
    sessionPath = [
      "$HOME/.npm/bin"
      "$HOME/.dotnet/tools"
      "$HOME/.local/bin"
    ];

    # Keep the npm-installed MCP browsers present declaratively: a fresh
    # machine (or a wiped $HOME/.npm) gets them back on the next switch
    # instead of failing with "Executable not found in PATH". Skips when
    # both binaries already run.
    activation.installMcpBrowsers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -x "$HOME/.npm/bin/bladebro" ] || [ ! -x "$HOME/.npm/bin/donsetch" ]; then
        $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm install --prefix "$HOME/.npm" -g bladebro donsetch
      fi
    '';
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
