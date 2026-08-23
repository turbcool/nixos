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
  # agenix). The OPUS/SONNET tiers map to the main deepseek model, HAIKU to the
  # qwen coder model; the picker lists every chat model the endpoint serves.
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
      custom = mkClaudeProfile {
        key = "custom"; # llm.naidanov.ru — Anthropic API at root
        label = "Claude Code (Custom)";
        mainModel = config.local.llm.defaultModel; # Opus/Sonnet tier
        haikuModel = config.local.llm.smallModel; # Haiku tier
        models = [
          {
            id = lib.removePrefix "custom/" config.local.llm.defaultModel;
            label = "Deepseek V4 Flash";
            isDefault = true;
          }
          {
            id = lib.removePrefix "custom/" config.local.llm.smallModel;
            label = "Qwen3-Coder Next";
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
