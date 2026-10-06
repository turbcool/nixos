# Provider tokens, host side. The agent-runtime flake ships no secrets: it
# declares `tokenSource.env` in data/providers.nix and this module points each
# provider at its ciphertext, so the agent-runtime NixOS module rewrites the
# tokenSource to the agenix store path.
#
# Everything else about these secrets (public keys, provisioning) stays in
# common/secrets/ — this file is only the map from provider name to file.
{ ... }:
{
  agent.agenixFiles = {
    neoplatform = ../secrets/neoplatform-token.age;
    custom = ../secrets/custom-token.age;
    free = ../secrets/free-token.age;
  };
}
