# Agenix secrets configuration
# This file defines which secrets can be accessed by which hosts/users
# Run `agenix -e <secret-name>.age` to edit secrets
# Run `agenix -r` to rekey secrets when SSH keys change
let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTqEJJ50htCOsmbULT7xdANQ/9ZRwrEdyTJyOAVHKOl";
in {
  "work-pc.age".publicKeys = [nixos];
}
