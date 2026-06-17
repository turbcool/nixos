{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  llm = osConfig.local.llm;
  cc = llm.claudeCode;
  ccProvider = llm.providers.${cc.provider};
  ccTokenPath = osConfig.age.secrets."${cc.provider}-token".path;
  ccBaseUrl = ccProvider.anthropicUrl or ccProvider.url;
  authExport =
    if (ccProvider.authToken or false) then
      ''export ANTHROPIC_AUTH_TOKEN="$(cat ${ccTokenPath})"''
    else
      ''export ANTHROPIC_API_KEY="$(cat ${ccTokenPath})"'';
in
{
  # The immutable Claude Code config (env, marketplaces, enabled plugins) is
  # emitted by the system module common/modules/llm.nix as
  # /etc/claude-code/managed-settings.json. This deliberately does NOT manage
  # ~/.claude/settings.json so that file stays a writable user-owned file that
  # Claude's plugin install flow can write to.
  config = lib.mkIf cc.enable {
    programs.zsh.initContent = ''
      ${authExport}
      export ANTHROPIC_BASE_URL="${ccBaseUrl}"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="${cc.models.opus}"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="${cc.models.sonnet}"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="${cc.models.haiku}"
      export CLAUDE_CODE_SUBAGENT_MODEL="${cc.models.subagent}"
      export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
    '';
  };
}
