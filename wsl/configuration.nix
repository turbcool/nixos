{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  profile = config.local.profile;
  username = profile.username;
  sshProxyPort = 22222;
  sshTargetPort = 22222;
  hostProxyUrl = "http://127.0.0.1:10809";
  noProxy = "192.168.*,172.31.*,172.30.*,172.29.*,172.28.*,172.27.*,172.26.*,172.25.*,172.24.*,172.23.*,172.22.*,172.21.*,172.20.*,172.19.*,172.18.*,172.17.*,172.16.*,10.*,127.*,localhost,<local>";
  sshProxyListenAddress = "0.0.0.0";
  sshProxyRuleName = "WSL NixOS SSH ${toString sshProxyPort}";
  sshHyperVRuleName = "WSL NixOS SSH ${toString sshProxyPort} Hyper-V";
  wslRefreshWindowsSshProxy = pkgs.writeShellScriptBin "wsl-refresh-windows-ssh-proxy" ''
    set -eu

    if [ ! -e /proc/sys/fs/binfmt_misc/WSLInterop ]; then
      echo "WSL Windows interop is not registered. Rebuild with wsl.interop.register = true and restart WSL first." >&2
      exit 1
    fi

    if [ ! -x /mnt/c/Windows/System32/netsh.exe ]; then
      echo "Windows netsh.exe is not available at /mnt/c/Windows/System32/netsh.exe" >&2
      exit 1
    fi

    if [ ${toString sshProxyPort} -ne ${toString sshTargetPort} ]; then
      default_dev="$(${pkgs.iproute2}/bin/ip -4 route show default | while read -r _ _ _ _ dev _; do
        printf '%s\n' "$dev"
        break
      done)"

      if [ -z "$default_dev" ]; then
        echo "Could not determine the default network interface" >&2
        exit 1
      fi

      wsl_ip="$(${pkgs.iproute2}/bin/ip -4 -o addr show dev "$default_dev" scope global | while read -r _ _ _ addr _; do
        printf '%s\n' "''${addr%%/*}"
        break
      done)"

      if [ -z "$wsl_ip" ]; then
        echo "Could not determine the current WSL IPv4 address for interface $default_dev" >&2
        exit 1
      fi

      /mnt/c/Windows/System32/netsh.exe interface portproxy delete v4tov4 listenaddress=${sshProxyListenAddress} listenport=${toString sshProxyPort} >/dev/null 2>&1 || true
      if ! /mnt/c/Windows/System32/netsh.exe interface portproxy add v4tov4 listenaddress=${sshProxyListenAddress} listenport=${toString sshProxyPort} connectaddress="$wsl_ip" connectport=${toString sshTargetPort}; then
        echo "Failed to create the Windows portproxy rule." >&2
        echo "Run this command from an elevated Windows terminal so WSL inherits administrator rights." >&2
        echo "Also make sure the Windows IP Helper service is running." >&2
        exit 1
      fi
    else
      /mnt/c/Windows/System32/netsh.exe interface portproxy delete v4tov4 listenaddress=${sshProxyListenAddress} listenport=${toString sshProxyPort} >/dev/null 2>&1 || true
    fi

    /mnt/c/Windows/System32/netsh.exe advfirewall firewall delete rule name="${sshProxyRuleName}" >/dev/null 2>&1 || true
    if ! /mnt/c/Windows/System32/netsh.exe advfirewall firewall add rule name="${sshProxyRuleName}" dir=in action=allow protocol=TCP localport=${toString sshProxyPort}; then
      echo "Failed to open Windows Firewall for port ${toString sshProxyPort}." >&2
      echo "Run this command from an elevated Windows terminal so WSL inherits administrator rights." >&2
      exit 1
    fi

    vm_creator_id="$('/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe' -NoProfile -Command "(Get-NetFirewallHyperVVMSetting | Select-Object -First 1 -ExpandProperty VMCreatorId)" | ${pkgs.coreutils}/bin/tr -d '\r')"
    if [ -z "$vm_creator_id" ]; then
      echo "Could not determine the Hyper-V VMCreatorId for WSL." >&2
      exit 1
    fi

    '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe' -NoProfile -Command "Get-NetFirewallHyperVRule | Where-Object DisplayName -eq '${sshHyperVRuleName}' | Remove-NetFirewallHyperVRule" >/dev/null 2>&1 || true
    if ! '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe' -NoProfile -Command "New-NetFirewallHyperVRule -DisplayName '${sshHyperVRuleName}' -Direction Inbound -VMCreatorId '$vm_creator_id' -Protocol TCP -LocalPorts ${toString sshTargetPort} -Action Allow"; then
      echo "Failed to create the Hyper-V firewall rule for WSL SSH on port ${toString sshTargetPort}." >&2
      echo "Run this command from an elevated Windows terminal so WSL inherits administrator rights." >&2
      exit 1
    fi

    if [ ${toString sshProxyPort} -eq ${toString sshTargetPort} ]; then
      echo "Windows host port ${toString sshProxyPort} is opened for direct WSL SSH access in mirrored networking mode."
    else
      echo "Windows host port ${toString sshProxyPort} now forwards to WSL ''${wsl_ip}:${toString sshTargetPort}."
    fi
  '';
in

{
  imports = [
    ../common/pkgs/default.nix
    ../common/modules/default.nix
  ];

  local.profile = {
    username = "turb";
    fullName = "Ilya Naidanov";
    email = "turbcool@gmail.com";
    timezone = "Asia/Yekaterinburg";
    locale = "ru_RU.UTF-8";
  };

  networking.hostName = "wsl";

  wsl = {
    enable = true;
    useWindowsDriver = true;
    defaultUser = username;
    docker-desktop.enable = true;
    interop.register = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    ports = [ sshTargetPort ];
    settings.SetEnv = lib.concatStringsSep " " [
      "HTTP_PROXY=${hostProxyUrl}"
      "HTTPS_PROXY=${hostProxyUrl}"
      "http_proxy=${hostProxyUrl}"
      "https_proxy=${hostProxyUrl}"
      "NO_PROXY=${noProxy}"
      "no_proxy=${noProxy}"
    ];
  };

  time.timeZone = profile.timezone;

  environment.sessionVariables = {
    HTTP_PROXY = hostProxyUrl;
    HTTPS_PROXY = hostProxyUrl;
    http_proxy = hostProxyUrl;
    https_proxy = hostProxyUrl;
    NO_PROXY = noProxy;
    no_proxy = noProxy;
  };

  nixpkgs.config.allowUnfree = true;

  age.identityPaths = [ "/home/${username}/.ssh/id_ed25519" ];

  environment.systemPackages = with pkgs; [
    wslRefreshWindowsSshProxy
  ];

  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "1";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.${username} =
      { ... }:
      {
        imports = [
          ../common/hm/default.nix
        ];
        home.stateVersion = "25.05";
      };
  };

  system.stateVersion = "25.05";
}
