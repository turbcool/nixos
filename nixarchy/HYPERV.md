# nixarchy in Hyper-V

`nixarchy-vm` = `nixarchy` + [`vm.nix`](./vm.nix): the physical hardware config is
overridden with a Generation 2 guest (Hyper-V kernel modules in initrd, disks by
label, no NVIDIA). Secrets are unchanged — the VM decrypts with the same
`~/.ssh/id_ed25519` that is already in `common/secrets/secrets.nix`.

## 1. Create the VM (Windows host)

Generation **2**, Secure Boot **off** (systemd-boot is unsigned), 4 vCPU, 8–16 GB
RAM, ~100 GB VHDX, *Default Switch* for networking. Then attach the NixOS ISO
and boot it.

```powershell
Set-VMFirmware -VMName "nixarchy" -EnableSecureBoot Off
```

## 2. Partition the VHDX (inside the ISO)

```bash
sudo -i
lsblk                                    # in the VM this is usually /dev/sda
export NIX_CONFIG="experimental-features = nix-command flakes"

parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart nixos ext4 512MiB 100%
mkfs.fat -F 32 -n ESP /dev/sda1          # labels are what vm.nix mounts
mkfs.ext4 -L nixos /dev/sda2

mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
```

## 3. Repo + agent runtime

The flake pins `agent-runtime = git+file:/home/turb/repos/agent-runtime`, so that
path must exist **in the live ISO** at the same absolute location.

```bash
git clone https://github.com/turbcool/nixos /mnt/etc/nixos
mkdir -p /mnt/home/turb/repos
git clone https://github.com/turbcool/agent-runtime /mnt/home/turb/repos/agent-runtime
mkdir -p /home/turb && ln -s /mnt/home/turb/repos /home/turb/repos
```

## 4. agenix identity

`nixos-install` runs activation, which decrypts the `agent`, `glab` and `vm-ssh`
secrets. Copy the key into the target before installing. Simplest way from a
console-only VM: serve it from Windows and fetch it (adjust the host IP):

```powershell
# on Windows, in the folder that has id_ed25519
python -m http.server 8000
```

```bash
install -d -m 700 /mnt/home/turb/.ssh
curl -o /mnt/home/turb/.ssh/id_ed25519 http://<windows-ip>:8000/id_ed25519
chmod 600 /mnt/home/turb/.ssh/id_ed25519
chown -R 1000:100 /mnt/home/turb
```

(Alternative: attach a second small FAT32 VHDX containing the key and mount it.)

## 5. Install

```bash
nixos-install --flake /mnt/etc/nixos#nixarchy-vm --no-root-passwd
reboot
```

## 6. First boot

- SDDM comes up with the Omarchy greeter and starts the `Nixarchy` session.
- If the greeter or Hyprland fails on the virtual GPU, log in on a TTY
  (`turb`, initial password `1` → run `passwd`) and start the session by hand:
  `uwsm start omarchy`
- SSH on port 22 is enabled and uses the same key:
  `ssh -i id_ed25519 turb@<vm-ip>`
- `sudo chown -R turb:users /etc/nixos /home/turb/repos` if you cloned as root.

## Notes

- Hyper-V guest video is `hyperv_drm` + llvmpipe: compositing works, GPU
  acceleration does not. For a real GPU, use Hyper-V GPU partitioning on a
  Windows 11 host, then drop the `videoDrivers`/`LIBGL_ALWAYS_SOFTWARE`
  overrides in `vm.nix`.
- The VM's disk UUIDs never enter the repo: `vm.nix` forces the `nixos` / `ESP`
  labels instead.