# Shared agenix secrets manifest.
#
# agenix only needs this while *editing* (encrypting); at evaluation the runtime
# derives the ciphertext paths from `agent.agenixDir`. Run, from here:
#   nix run nixos#agenix -e neoplatform-token.age
let
  pubkeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAinMWGCX0qwJCprj4pAn+bSx+w2YGr8z6yqsMPuyi0X"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTqEJJ50htCOsmbULT7xdANQ/9ZRwrEdyTJyOAVHKOl"
  ];
  mk = name: {
    name = name;
    value = { publicKeys = pubkeys; };
  };
in
builtins.listToAttrs (
  map mk [
    "neoplatform-token.age"
    "custom-token.age"
    "free-token.age"
    "gitlab-neoplatform-token.age"
    "gitlab-skyori-token.age"
    "vm-ai-neoplatform.age"
    "vm-ai-proinfoservice.age"
    "vm-ai-skyori.age"
    "vm-ai-timepath.age"
  ]
) // {
  "../../hydenix/secrets/work-pc.age" = { publicKeys = pubkeys; };
}
