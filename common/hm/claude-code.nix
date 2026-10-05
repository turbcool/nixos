# Claude Code for interactive shells.
#
# The immutable half of the config (marketplaces, enabled plugins,
# CLAUDE_CODE_SUBAGENT_MODEL) is emitted by the agent-runtime NixOS module as
# /etc/claude-code/managed-settings.json. This deliberately does NOT manage
# ~/.claude/settings.json so that file stays a writable user-owned file that
# Claude's plugin install flow can write to.
#
# The exports here are the *default* endpoint for a bare `claude` typed in a
# shell. The per-provider wrappers (claude, claude-free) shipped by
# agent-runtime/modules/wrappers.nix override them for their own process, which
# is why they live in initContent rather than in environment.sessionVariables.
{
  config,
  lib,
  ...
}:

let
  agent = config.agent;
  cc = agent.claudeCode;
  ccProvider = agent.providers.${cc.provider};
  ccBaseUrl = ccProvider.anthropicUrl or ccProvider.url;
in
{
  config = lib.mkIf cc.enable {
    programs.zsh.initContent = ''
      export ANTHROPIC_API_KEY=${agent.tokenSyntax.${cc.provider}.shell}
      export ANTHROPIC_BASE_URL="${ccBaseUrl}"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="${cc.mainModel}"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="${cc.mainModel}"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="${cc.smallModel}"
      export CLAUDE_CODE_SUBAGENT_MODEL="${cc.smallModel}"
      export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
    '';
  };
}
