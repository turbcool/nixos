# NixOS -> Home Manager bridge for the agent runtime.
#
# `agent-runtime`'s modules/home.nix is OS-agnostic: it reads
# `agent.providers`, whose defaults are the env-var token sources from
# agent-runtime/data/providers.nix. On NixOS the agent-runtime NixOS module has
# already rewritten every provider that has an `agenixFile` to point at the
# decrypted secret's store path (`agent.resolvedProviders`), so copy that set
# over. Standalone (containers) there is no osConfig and the env-var defaults
# are used as-is.
{ osConfig, ... }:

{
  agent.providers = osConfig.agent.resolvedProviders;
}
