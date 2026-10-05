# The `claude` / `claude-free` / `writing` command wrappers.
#
# Each wrapper pins one provider for its own process only: it exports the
# provider's ANTHROPIC_* env, then execs the real claude with a resolved MCP
# config. That env overrides any global shell export, so one wrapper per
# endpoint is all it takes to run the same binary against several providers.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.agent;
  inherit (cfg) providers;

  inherit (pkgs.stdenv.hostPlatform) system;
  realClaude = inputs.claude-code.packages.${system}.default;

  cc = cfg.claudeCode;

  # Claude Code MCP config, sourced from data/mcp.nix. Built into the store as
  # a template: it carries @@SECRET:<name>@@ / @@ENV:<VAR>@@ sentinels, never
  # real keys.
  # Commands are rewritten to absolute $HOME/.npm/bin paths: the wrapper runs
  # inside the agent's environment, which may predate home.sessionPath (e.g.
  # GUI-launched, or a container with no shell rc) — never rely on PATH.
  claudeMcpTemplate = pkgs.writeText "claude-code-mcp.json" (
    builtins.toJSON {
      mcpServers = lib.mapAttrs (
        name: srv: srv // { command = "${config.home.homeDirectory}/.npm/bin/${name}"; }
      ) cfg.mcp.claudeCode;
    }
  );

  # Resolves the managed MCP config (secrets land to a mode-0600 file under the
  # user's cache dir — never the store or CLI args) and execs the real claude
  # with it. Falls back to plain `claude` if anything goes wrong.
  mkClaudeMcp = binName: ''
    umask 077   # resolved secrets land in $out — never world/group readable
    real="${realClaude}/bin/claude"
    out="''${XDG_CACHE_HOME:-$HOME/.cache}/claude-code/mcp-${binName}.json"
    ok=0
    if mkdir -p "$(dirname "$out")" 2>/dev/null; then
      json="$(cat ${claudeMcpTemplate})"
      while [[ "$json" == *"@@SECRET:"* ]]; do
        name="''${json#*@@SECRET:}"
        name="''${name%%@@*}"
        json="''${json/@@SECRET:$name@@/$(cat "/run/agenix/$name" 2>/dev/null || true)}"
      done
      while [[ "$json" == *"@@ENV:"* ]]; do
        var="''${json#*@@ENV:}"
        var="''${var%%@@*}"
        json="''${json/@@ENV:$var@@/''${!var:-}}"
      done
      if printf '%s\n' "$json" > "$out" 2>/dev/null; then
        chmod 600 "$out"   # umask only governs creation; fix pre-existing perms too
        ok=1
      fi
    fi
    exec "$real" --mcp-config="$out" "$@"
  '';

  # One provider-pinned claude wrapper. Non-strict --mcp-config, so it merges
  # with ~/.claude.json and project .mcp.json servers, and `claude mcp add`
  # keeps working.
  mkClaudeWrapper = w: ''
    export ANTHROPIC_BASE_URL="${providers.${w.provider}.anthropicUrl or providers.${w.provider}.url}"
    export ANTHROPIC_API_KEY=${cfg.tokenSyntax.${w.provider}.shell}
    export ANTHROPIC_DEFAULT_OPUS_MODEL="${w.mainModel}"
    export ANTHROPIC_DEFAULT_SONNET_MODEL="${w.mainModel}"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="${w.smallModel}"
    export CLAUDE_CODE_SUBAGENT_MODEL="${w.smallModel}"
    ${mkClaudeMcp w.name}
  '';

  # The default `claude`: whatever claudeCode.provider/mainModel/smallModel say.
  # Its env overrides the global exports from common/hm/claude-code.nix for
  # this process only.
  defaultWrapper = {
    name = "claude";
    provider = cc.provider;
    inherit (cc) mainModel;
    inherit (cc) smallModel;
    comment = "Primary Claude Code wrapper (managed-settings.json stays in modules/nixos.nix).";
  };

  wrappers = lib.optionals cc.enable (
    map (w: pkgs.writeShellScriptBin w.name (mkClaudeWrapper w)) (
      [ defaultWrapper ] ++ cfg.claudeCode.wrappers
    )
  );

  # `writing` prepares the current folder for ARIS (Auto-Research-In-Sleep):
  # clones the skill repo to ~/aris_repo (once) and symlinks its skills into
  # .claude/skills/ here, so launching `claude` exposes the research/writing
  # slash-commands (/research-pipeline, /paper-writing, ...). It also repoints
  # Claude Code at the custom provider (llm.naidanov.ru / deepseek-v4-flash) for
  # this folder only, via .claude/settings.local.json. Folder-local — the Codex
  # MCP reviewer (for cross-model review skills) is a global, one-time step and
  # is printed, not run.
  # https://github.com/wanshuiyin/auto-claude-code-research-in-sleep
  writing = pkgs.writeShellScriptBin "writing" ''
    set -euo pipefail

    # jq isn't a system-wide package (only in the host flake's devShell), and
    # `writing` runs from arbitrary folders — so invoke it by its absolute store
    # path instead of relying on PATH.
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

    # 3. Repoint Claude Code at the custom provider (llm.naidanov.ru /
    # deepseek-v4-flash for Opus/Sonnet, qwen3-coder-next for Haiku) for THIS
    # folder only, by merging an env block into .claude/settings.local.json.
    #    That file sits below the immutable managed-settings.json but ABOVE the
    #    global exports from .zshrc, so it cleanly overrides ANTHROPIC_BASE_URL,
    #    the token (both AUTH_TOKEN and API_KEY, so Claude's auth-precedence
    #    can't pick a stale value), and the model tiers. Token is read fresh and
    #    written mode-0600; jq merges so existing keys (permissions, ...) survive.
    #    NOTE: managed-settings.json locks CLAUDE_CODE_SUBAGENT_MODEL
    #    system-wide, so subagents keep the global model — change
    #    agent.claudeCode.smallModel in the host's HM config if the custom
    #    endpoint rejects the global id.
    sfile="$PWD/.claude/settings.local.json"
    mkdir -p "$PWD/.claude"
    tok=${cfg.tokenSyntax.custom.shell}
    if [ -z "$tok" ]; then
      echo "✗ Custom provider token unavailable (${
        providers.custom.tokenSource.env or providers.custom.tokenSource.file
      })"
      echo "  Export it, or provision the agenix 'custom-token' secret on NixOS, then re-run 'writing'."
      exit 1
    fi
    base="$(cat "$sfile" 2>/dev/null || echo '{}')"
    "$JQ" -e . >/dev/null 2>&1 <<<"$base" || base='{}'
    merged="$("$JQ" --arg url "${providers.custom.url}" --arg key "$tok" --arg m "deepseek-v4-flash" --arg h "qwen3-coder-next" \
      '.env = ((.env // {}) + {
         "ANTHROPIC_BASE_URL": $url,
         "ANTHROPIC_AUTH_TOKEN": $key,
         "ANTHROPIC_API_KEY": $key,
         "ANTHROPIC_DEFAULT_OPUS_MODEL": $m,
         "ANTHROPIC_DEFAULT_SONNET_MODEL": $m,
         "ANTHROPIC_DEFAULT_HAIKU_MODEL": $h
       })' <<<"$base")"
    ( umask 077; printf '%s\n' "$merged" > "$sfile" )
    chmod 600 "$sfile"   # umask only governs creation; clamp a pre-existing file too
    echo "› Claude → custom provider (${providers.custom.url}, opus/sonnet=deepseek-v4-flash, haiku=qwen3-coder-next) via $sfile"

    # 4. Cross-model review skills need the Codex MCP reviewer — a global,
    #    one-time step. Print it; don't mutate ~/.claude.json from here.
    echo ""
    echo "✅ ARIS ready in this folder (Claude → ${providers.custom.url}). Next: run  claude"
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
  # Appended to agent.runtimePackages; modules/home.nix mirrors that into
  # home.packages so the container bundle and a desktop login get exactly the
  # same set.
  config.agent.runtimePackages =
    wrappers
    ++ lib.optionals cc.enable [ writing ]
    # The real binary is normally reachable only through the wrappers (which
    # exec it by absolute store path). Opt in if something needs an unwrapped
    # `claude` on PATH — but then it collides with the wrapper.
    ++ lib.optionals (cc.enable && cc.exposeRealBinary) [ realClaude ];
}
