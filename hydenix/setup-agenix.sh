#!/bin/bash

# Setup script for agenix secrets management

echo "Setting up agenix for NixOS secrets management..."

# Check if SSH key exists
if [ ! -f ~/.ssh/id_ed25519.pub ]; then
    echo "No SSH key found. Generating new SSH key..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
    echo "SSH key generated at ~/.ssh/id_ed25519"
fi

# Get the SSH public key
SSH_PUB_KEY=$(cat ~/.ssh/id_ed25519.pub)
echo "Your SSH public key: $SSH_PUB_KEY"

# Update secrets.nix with your SSH key
echo "Updating secrets.nix with your SSH public key..."
sed -i "s|# Add your SSH public keys here|\"$SSH_PUB_KEY\"|g" secrets.nix

# Create encrypted secrets
echo ""
echo "Now creating encrypted secrets..."
echo ""
echo "Please enter your WORK-PC Remmina password:"
read -s WORK_PC_PASSWORD
echo -n "$WORK_PC_PASSWORD" | agenix -e secrets/remmina-work-pc.age

echo ""
echo "Please enter your AutoCam Remmina password:"
read -s AUTOCAM_PASSWORD
echo -n "$AUTOCAM_PASSWORD" | agenix -e secrets/remmina-autocam.age

echo ""
echo "Please enter your VPN password:"
read -s VPN_PASSWORD
echo -n "$VPN_PASSWORD" | agenix -e secrets/vpn-password.age

echo ""
echo "Setup complete!"
echo ""
echo "To rebuild your system with secrets:"
echo "sudo nixos-rebuild switch --flake .#hydenix"
echo ""
echo "To edit secrets later:"
echo "agenix -e secrets/remmina-work-pc.age"
echo "agenix -e secrets/remmina-autocam.age"
echo "agenix -e secrets/vpn-password.age"