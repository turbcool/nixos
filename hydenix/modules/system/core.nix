# Base system settings
{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" "btrfs" ];
  fileSystems."/mnt/windows" = {
    device = "/dev/nvme0n1p2";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" ];
  };
  fileSystems."/mnt/windows_old" = {
    device = "/dev/sda4";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" ];
  };
}
