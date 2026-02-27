#!/bin/sh
# HYDENIX INSTALLATION SCRIPT

# Function to handle errors
die() {
    echo "Error: $1" >&2
    exit 1
}

# Install git if not already present
if ! command -v git >/dev/null 2>&1; then
    echo "Installing git..."
    sudo sed -i '/environment\.systemPackages =/,/];/ { /];/ i\      git }' /etc/nixos/configuration.nix || die "Failed to modify configuration.nix"
    sudo nixos-rebuild switch || die "Failed to rebuild with git"
else
    echo "git is already installed."
fi

# Backup and replace NixOS config
echo "WARNING: This will replace your existing /etc/nixos configuration!"
[ -d /etc/nixos ] && sudo mv /etc/nixos /etc/nixos_backup || echo "No existing /etc/nixos to back up"
sudo git clone https://github.com/turbcool/nixos /etc/nixos || die "Failed to clone repository"

# Update hardware configuration
[ -d /etc/nixos/hydenix ] || die "/etc/nixos/hydenix not found"
sudo rm -f /etc/nixos/hydenix/hardware-configuration.nix || die "Failed to remove hardware config"
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hydenix/hardware-configuration.nix || die "Failed to generate hardware config"

# Build HYDENIX flake
cd /etc/nixos/hydenix || die "Cannot cd to /etc/nixos/hydenix"
sudo nixos-rebuild switch --flake ".#nixos" || die "Failed to rebuild flake"
