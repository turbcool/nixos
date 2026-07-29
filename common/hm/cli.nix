{
  inputs,
  osConfig,
  lib,
  pkgs,
  ...
}:

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

  # Custom provider that `writing` repoints Claude Code at, folder-locally. Same
  # endpoint + agenix token as providers.custom (llm.naidanov.ru). `glm-5.2` is
  # the model id that endpoint serves (per its /v1/models).
  ccCustom = osConfig.local.llm.providers.custom;
  ccCustomUrl = ccCustom.url;
  ccCustomToken = osConfig.age.secrets."custom-token".path;
  ccCustomModel = "glm-5.2";

  # `writing` prepares the current folder for ARIS (Auto-Research-In-Sleep):
  # clones the skill repo to ~/aris_repo (once) and symlinks its skills into
  # .claude/skills/ here, so launching `claude` exposes the research/writing
  # slash-commands (/research-pipeline, /paper-writing, ...). It also repoints
  # Claude Code at the custom provider (llm.naidanov.ru / glm-5.2) for this
  # folder only, via .claude/settings.local.json. Folder-local — the Codex MCP
  # reviewer (for cross-model review skills) is a global, one-time step and is
  # printed, not run.
  # https://github.com/wanshuiyin/auto-claude-code-research-in-sleep
  writing = pkgs.writeShellScriptBin "writing" ''
    set -euo pipefail

    # jq isn't a system-wide package (only in this flake's devShell), and `writing`
    # runs from arbitrary folders — so invoke it by its absolute store path instead
    # of relying on PATH.
    JQ="${pkgs.jq}/bin/jq"

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

    # 3. Repoint Claude Code at the custom provider (llm.naidanov.ru / glm-5.2)
    #    for THIS folder only, by merging an env block into .claude/settings.local.json.
    #    That file sits below the immutable managed-settings.json but ABOVE the global
    #    zai exports from .zshrc, so it cleanly overrides ANTHROPIC_BASE_URL, the token
    #    (both AUTH_TOKEN and API_KEY, so Claude's auth-precedence can't pick the stale
    #    zai value), and the model tiers. Token is read fresh from agenix and written
    #    mode-0600; jq merges so existing keys (permissions, ...) survive.
    #    NOTE: managed-settings.json locks CLAUDE_CODE_SUBAGENT_MODEL system-wide, so
    #    subagents keep the global model — change it in common/modules/llm.nix if the
    #    custom endpoint rejects the global id.
    sfile="$PWD/.claude/settings.local.json"
    mkdir -p "$PWD/.claude"
    if [ ! -r "${ccCustomToken}" ]; then
      echo "✗ Custom provider token missing (${ccCustomToken})"
      echo "  Provision the agenix 'custom-token' secret, then re-run 'writing'."
      exit 1
    fi
    tok="$(cat "${ccCustomToken}")"
    base="$(cat "$sfile" 2>/dev/null || echo '{}')"
    "$JQ" -e . >/dev/null 2>&1 <<<"$base" || base='{}'
    merged="$("$JQ" --arg url "${ccCustomUrl}" --arg key "$tok" --arg m "${ccCustomModel}" \
      '.env = ((.env // {}) + {
         "ANTHROPIC_BASE_URL": $url,
         "ANTHROPIC_AUTH_TOKEN": $key,
         "ANTHROPIC_API_KEY": $key,
         "ANTHROPIC_DEFAULT_OPUS_MODEL": $m,
         "ANTHROPIC_DEFAULT_SONNET_MODEL": $m,
         "ANTHROPIC_DEFAULT_HAIKU_MODEL": $m
       })' <<<"$base")"
    ( umask 077; printf '%s\n' "$merged" > "$sfile" )
    chmod 600 "$sfile"   # umask only governs creation; clamp a pre-existing file too
    echo "› Claude → custom provider (${ccCustomUrl}, ${ccCustomModel}) via $sfile"

    # 4. Cross-model review skills need the Codex MCP reviewer — a global,
    #    one-time step. Print it; don't mutate ~/.claude.json from here.
    echo ""
    echo "✅ ARIS ready in this folder (Claude → ${ccCustomUrl}). Next: run  claude"
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
      hound = "hound-toggle";
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
      hound-toggle() {
        local compose="$HOME/hound-mcp/docker-compose.yml"
        if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^hound$'; then
          echo "→ Hound is running — stopping ..."
          docker compose -f "$compose" down
          echo "✓ Hound stopped"
        else
          echo "→ Hound is stopped — starting ..."
          docker compose -f "$compose" up -d --wait
          echo "✓ Hound started (http://localhost:8765/mcp)"
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
