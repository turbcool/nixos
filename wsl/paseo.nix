{
  config,
  lib,
  pkgs,
  ...
}:

let
  llmProviders = config.local.llm.providers;

  # Build a paseo "Claude Code" profile that reuses the claude agent backend
  # (extends "claude"), points it at a provider's Anthropic endpoint, and lists
  # only that provider's models (defaults removed via `models`, which replaces
  # the inherited catalog rather than appending).
  #
  # Models were discovered from each provider's /models endpoint (keys in
  # agenix). The OPUS/SONNET tiers map to the main GLM model, HAIKU to a small
  # coder model; the picker lists every chat model the endpoint serves.
  mkClaudeProfile =
    {
      key,
      label,
      mainModel,
      haikuModel,
      models,
    }:
    let
      p = llmProviders.${key};
    in
    {
      extends = "claude";
      inherit label;
      env = {
        ANTHROPIC_BASE_URL = p.anthropicUrl or p.url;
        ANTHROPIC_AUTH_TOKEN = "@@SECRET:${key}-token@@";
        ANTHROPIC_DEFAULT_OPUS_MODEL = mainModel;
        ANTHROPIC_DEFAULT_SONNET_MODEL = mainModel;
        ANTHROPIC_DEFAULT_HAIKU_MODEL = haikuModel;
      };
      inherit models;
    };

  # config.json template carrying @@SECRET:<name>@@ sentinels. Substituted from
  # /run/agenix at service start (preStart below) so tokens never enter the store.
  templateFile = (pkgs.formats.json { }).generate "paseo-config.json" config.services.paseo.settings;
in
{
  services.paseo = {
    enable = true;
    user = config.local.profile.username;
    listenAddress = "0.0.0.0";
    port = 6767;
    openFirewall = true;

    settings.agents.providers = {
      zai = mkClaudeProfile {
        key = "zai";
        label = "Claude Code (Z.AI)";
        mainModel = config.local.llm.claudeCode.models.opus; # glm-5.2[1m] (1M ctx)
        haikuModel = "glm-4.5-air"; # z.ai has no qwen; smallest GLM
        models = [
          {
            id = config.local.llm.claudeCode.models.opus;
            label = "GLM-5.2 1M";
            isDefault = true;
          }
          {
            id = "glm-4.5-air";
            label = "GLM-4.5 Air";
          }
        ];
      };
      custom = mkClaudeProfile {
        key = "custom"; # llm.naidanov.ru — Anthropic API at root
        label = "Claude Code (Naidanov)";
        mainModel = "glm-5.2"; # plain id (no [1m]) — naidanov doesn't speak the suffix
        haikuModel = "qwen3-coder-next";
        # Every chat model llm.naidanov.ru serves (embedding models excluded).
        # glm-5.2 is the default; qwen3-coder-next backs the HAIKU tier.
        models = [
          {
            id = "glm-5.2";
            label = "GLM-5.2";
            isDefault = true;
          }
          {
            id = "qwen3-coder-next";
            label = "Qwen3-Coder Next";
          }
          {
            id = "glm-5.2-direct";
            label = "GLM-5.2 Direct";
          }
          {
            id = "glm-5.2-zen";
            label = "GLM-5.2 Zen";
          }
          {
            id = "qwen3.6-200k";
            label = "Qwen3.6 200K";
          }
          {
            id = "deepseek-v4-flash";
            label = "DeepSeek V4 Flash";
          }
          {
            id = "deepseek-v4-flash-zen";
            label = "DeepSeek V4 Flash Zen";
          }
          {
            id = "kimi-k2.7-code-zen";
            label = "Kimi K2.7 Code Zen";
          }
          {
            id = "minimax-m3-zen";
            label = "MiniMax M3 Zen";
          }
        ];
      };

      # Hide the built-in Claude Code entry (shows Anthropic defaults, no auth).
      # Disabling the entry does not unregister the claude backend, so the
      # extends="claude" profiles above still resolve.
      claude.enabled = false;
    };
  };

  # Render config.json with @@SECRET:<name>@@ -> /run/agenix/<name>, then install.
  # Overrides paseo's default preStart (which installs the store template
  # verbatim). Mirrors the @@SECRET substitution in the claude MCP wrapper
  # (common/hm/cli.nix). A missing secret substitutes to empty (graceful) and
  # the file is still written, so paseo always starts.
  systemd.services.paseo.preStart = lib.mkForce ''
    set -e
    umask 077
    f="${config.services.paseo.dataDir}/config.json"
    json="$(cat ${templateFile})"
    while [[ "$json" == *"@@SECRET:"* ]]; do
      name="''${json#*@@SECRET:}"
      name="''${name%%@@*}"
      json="''${json/@@SECRET:$name@@/$(cat "/run/agenix/$name" 2>/dev/null || true)}"
    done
    printf '%s\n' "$json" > "$f"
    chmod 600 "$f"
  '';
}
