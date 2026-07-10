{ inputs, lib, pkgs, ... }:

let
  realClaude = inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Claude Code MCP config, sourced from config/mcp.nix. Built into the store as
  # a template: it carries @@SECRET:<name>@@ sentinels, never real keys.
  claudeMcpTemplate = pkgs.writeText "claude-code-mcp.json" (
    builtins.toJSON {
      mcpServers = (import ../../config/mcp.nix).claudeCode;
    }
  );

  # Wraps `claude` so every invocation gets the managed MCP config via
  # --mcp-config. Non-strict, so it merges with ~/.claude.json and project
  # .mcp.json servers, and `claude mcp add` keeps working. The resolved config
  # (the only place secrets land) is a mode-0600 file under the user's cache dir
  # — never the store or CLI args. Falls back to plain `claude` if anything goes
  # wrong, so the binary is never broken by MCP config issues.
  claudeWithMcp = lib.hiPrio (pkgs.writeShellScriptBin "claude" ''
    umask 077   # resolved secrets land in $out — never world/group readable
    real="${realClaude}/bin/claude"
    out="''${XDG_CACHE_HOME:-$HOME/.cache}/claude-code/mcp.json"
    ok=0
    if mkdir -p "$(dirname "$out")" 2>/dev/null; then
      json="$(cat ${claudeMcpTemplate})"
      while [[ "$json" == *"@@SECRET:"* ]]; do
        name="''${json#*@@SECRET:}"
        name="''${name%%@@*}"
        json="''${json/@@SECRET:$name@@/$(cat "/run/agenix/$name" 2>/dev/null || true)}"
      done
      if printf '%s\n' "$json" > "$out" 2>/dev/null; then
        chmod 600 "$out"   # umask only governs creation; fix pre-existing perms too
        ok=1
      fi
    fi
    if [ "$ok" = 1 ]; then
      # `=` form is essential: --mcp-config is variadic, so `--mcp-config "$out"
      # mcp list` would swallow `mcp`/`list` as extra config files. The `=` form
      # delimits a single value and leaves "$@" (subcommands, flags) intact.
      exec "$real" --mcp-config="$out" "$@"
    fi
    exec "$real" "$@"
  '');

  # `writing` prepares the current folder for ARIS (Auto-Research-In-Sleep):
  # clones the skill repo to ~/aris_repo (once) and symlinks its skills into
  # .claude/skills/ here, so launching `claude` exposes the research/writing
  # slash-commands (/research-pipeline, /paper-writing, ...). Folder-local only
  # — the Codex MCP reviewer (for cross-model review skills) is a global,
  # one-time step and is printed, not run.
  # https://github.com/wanshuiyin/auto-claude-code-research-in-sleep
  writing = pkgs.writeShellScriptBin "writing" ''
    set -euo pipefail

    REPO="''${ARIS_REPO:-$HOME/aris_repo}"
    URL="https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep.git"

    # 1. Ensure the ARIS repo exists in a stable location (clone once).
    #    Bounded by `timeout` + --progress so a flaky/proxied network can't make
    #    the clone hang silently; point at the 'proxy' toggle on failure.
    if [ ! -d "$REPO/.git" ]; then
      echo "› Cloning ARIS → $REPO"
      if ! timeout 180 git clone --progress --depth 1 "$URL" "$REPO"; then
        echo "✗ Clone failed or timed out."
        echo "  GitHub may need a proxy — run 'proxy' to enable it, then retry 'writing'."
        exit 1
      fi
    else
      echo "› Updating ARIS ($REPO)"
      git -C "$REPO" pull --ff-only 2>/dev/null || echo "  (could not update — continuing with the local copy)"
    fi

    # 2. Install ARIS skills into this folder (.claude/skills/<name> symlinks).
    #    The installer prompts "Apply these N changes?" — feed 'y' so `writing`
    #    is one-shot. Its safety rules *abort* (never prompt) on real conflicts,
    #    so auto-confirming the apply gate is safe. Finite printf => no SIGPIPE
    #    under pipefail.
    echo "› Installing ARIS skills into: $PWD"
    printf 'y\ny\ny\ny\n' | bash "$REPO/tools/install_aris.sh" "$PWD"

    # Verify skills actually landed (the installer returns 0 even on user-abort,
    # so an empty result would otherwise look like success).
    skills_dir="$PWD/.claude/skills"
    if [ ! -d "$skills_dir" ] || [ -z "$(ls -A "$skills_dir" 2>/dev/null)" ]; then
      echo "✗ No ARIS skills were linked into $skills_dir"
      exit 1
    fi
    echo "› $(ls -1 "$skills_dir" | wc -l | tr -d ' ') skill(s) linked into $skills_dir"

    # 3. Cross-model review skills need the Codex MCP reviewer — a global,
    #    one-time step. Print it; don't mutate ~/.claude.json from here.
    echo ""
    echo "✅ ARIS ready in this folder. Next: run  claude"
    echo "   then try a workflow, e.g.:"
    echo '     /research-pipeline "your research direction"'
    echo '     /paper-writing "NARRATIVE_REPORT.md"'
    if command -v codex >/dev/null 2>&1; then
      echo ""
      echo "💡 Codex is installed — enable review skills (run once):"
      echo "     claude mcp add codex -s user -- codex mcp-server"
    else
      echo ""
      echo "💡 For review skills, install Codex and add it as an MCP server:"
      echo "     npm i -g @openai/codex && claude mcp add codex -s user -- codex mcp-server"
    fi
  '';
in
{
  home.packages = [
    pkgs.yt-dlp
    realClaude
    claudeWithMcp
    writing
  ];

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
    initExtra = ''
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

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];
}
