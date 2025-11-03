# Base system settings
{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" "btrfs" ];
  fileSystems."/mnt/windows" = {
    device = "/dev/nvme0n1p2";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "windows_names" "noatime" "big_writes" ];
  };

  fileSystems."/mnt/windows_old" = {
    device = "/dev/sda4";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "windows_names" "noatime" "big_writes" ];
  };
}
