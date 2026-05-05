# Shared agenix secrets configuration.
# Run `nix shell github:ryantm/agenix -c agenix -e flexberry-token.age` from this directory to edit shared secrets.
let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTqEJJ50htCOsmbULT7xdANQ/9ZRwrEdyTJyOAVHKOl";
in {
  "flexberry-token.age".publicKeys = [nixos];
  "custom-token.age".publicKeys = [nixos];
  "../../hydenix/secrets/work-pc.age".publicKeys = [nixos];
}
