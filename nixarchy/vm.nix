# Hyper-V guest overlay for nixarchy.
#
# nixarchy/configuration.nix imports the physical machine's
# hydenix/hardware-configuration.nix, so this module replaces exactly the parts
# that do not exist in a VM: the disk UUIDs, the KVM module, the NVIDIA stack,
# the physical NIC and the NTFS mounts from hydenix/modules/system/base.
#
# Disks are identified by label, so no VM-specific UUID has to be committed.
# Format them this way before nixos-install (Generation 2 / UEFI):
#
#   parted /dev/sda -- mklabel gpt
#   parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
#   parted /dev/sda -- set 1 esp on
#   parted /dev/sda -- mkpart nixos ext4 512MiB 100%
#   mkfs.fat -F 32 -n ESP /dev/sda1
#   mkfs.ext4 -L nixos /dev/sda2
{ lib, ... }:

{
  # hv_vmbus/hv_storvsc/hv_netvsc/hv_utils/hv_balloon into initrd, plus the
  # hyperv-daemons (KVP, time sync, dynamic memory, clean shutdown). Without it
  # the initrd never sees the synthetic SCSI disk and boot hangs waiting for
  # the root device.
  virtualisation.hypervGuest.enable = true;

  # Generation 2 guest video is hyperv_drm, a KMS driver with no GPU behind it.
  # The physical config's kvm-intel is dropped (it needs nested virtualisation).
  boot.kernelModules = lib.mkForce [ "hyperv_drm" ];

  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = lib.mkForce {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # No NVIDIA device unless the VM is given one with Hyper-V GPU partitioning.
  # Keeping videoDrivers=nvidia would build the driver for the guest kernel and
  # then fail to start a session; the modesetting driver + llvmpipe over
  # hyperv_drm is the sane default (also lets SDDM's X server start).
  services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
  hardware.nvidia = lib.mkForce { };
  hardware.nvidia-container-toolkit.enable = lib.mkForce false;
  environment.sessionVariables.LIBGL_ALWAYS_SOFTWARE = "1";

  # Physical-machine leftovers pulled in via hydenix/modules/system/base.
  networking.interfaces.enp6s0.wakeOnLan.enable = lib.mkForce false;
  fileSystems."/mnt/windows" = lib.mkForce {
    device = "/dev/disk/by-label/no-windows";
    fsType = "ntfs3";
    options = [
      "noauto"
      "nofail"
    ];
  };
  fileSystems."/mnt/windows_old" = lib.mkForce {
    device = "/dev/disk/by-label/no-windows";
    fsType = "ntfs3";
    options = [
      "noauto"
      "nofail"
    ];
  };

  # The agenix identity is already ~/.ssh/id_ed25519, so key-based SSH works on
  # first boot without extra setup.
  services.openssh = {
    enable = true;
    openFirewall = true;
  };
}
