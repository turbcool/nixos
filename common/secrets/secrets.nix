# Shared agenix secrets configuration.
# Run `nix shell github:ryantm/agenix -c agenix -e neoplatform-token.age` from this directory to edit shared secrets.
let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAinMWGCX0qwJCprj4pAn+bSx+w2YGr8z6yqsMPuyi0X";
  nixos-old = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTqEJJ50htCOsmbULT7xdANQ/9ZRwrEdyTJyOAVHKOl";
in
{
  "neoplatform-token.age".publicKeys = [ nixos nixos-old ];
  "custom-token.age".publicKeys = [ nixos nixos-old ];
  "../../hydenix/secrets/work-pc.age".publicKeys = [ nixos nixos-old ];
  "vm-ai-neoplatform.age".publicKeys = [ nixos nixos-old ];
  "vm-ai-skyori.age".publicKeys = [ nixos nixos-old ];
  "vm-ai-proinfoservice.age".publicKeys = [ nixos nixos-old ];
  "vm-ai-timepath.age".publicKeys = [ nixos nixos-old ];
  "zai-token.age".publicKeys = [ nixos nixos-old ];
  "free-token.age".publicKeys = [ nixos nixos-old ];
}
