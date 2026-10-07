# Host-side agent runtime config on a NixOS host: provider ciphertexts,
# host-only skills, and — because the runtime's NixOS module auto-injects the
# home half via `home-manager.sharedModules` — nothing else. The runtime does
# not ship secrets, so the .age files live here; their public keys live in
# common/secrets/secrets.nix.
{ config, inputs, ... }:

{
  # Ciphertext by provider name; each decrypts to /run/agenix/<provider>-token
  # (mode 0400, owner = local.profile.username). The convention
  # `agent.agenixDir = <dir>` maps every provider to `<dir>/<provider>-token.age`,
  # so a directory covering the registry is one line; add a stray provider to
  # `agent.agenixFiles` instead.
  agent.agenixDir = ../secrets;

  # Host-only skills, merged by the runtime's modules/skills.nix into the same
  # source set as its own skills — one catalog, one bundle, one sync.
  agent.skills.sources = import ../../config/skills.nix { inputs = inputs; };
}
