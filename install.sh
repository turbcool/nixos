FLAKE="github:nixos-asia/website?dir=global/nixos-install-oneclick#oneclick"
DISK_DEVICE="/dev/vda"
sudo nix \
    --extra-experimental-features 'flakes nix-command' \
    run github:nix-community/disko#disko-install -- \
    --flake "$FLAKE" \
    --write-efi-boot-entries \
    --disk main "$DISK_DEVICE"
