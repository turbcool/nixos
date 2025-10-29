# Agenix secrets configuration
# This file defines which secrets can be accessed by which hosts/users
# Run `agenix -e <secret-name>.age` to edit secrets
# Run `agenix -r` to rekey secrets when SSH keys change

{
  "remmina-work-pc.age".publicKeys = [
    # Add your SSH public keys here
    # You can get your SSH public key with: cat ~/.ssh/id_ed25519.pub
    # Or generate a new one with: ssh-keygen -t ed25519
  ];
  "remmina-autocam.age".publicKeys = [
    # Add your SSH public keys here
  ];
  "vpn-password.age".publicKeys = [
    # Add your SSH public keys here
  ];
}