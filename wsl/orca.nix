{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.services.orcaServer;
  package = inputs.orca-nix.packages.${pkgs.stdenv.hostPlatform.system}.orca;
in
{
  options.services.orcaServer = {
    enable = lib.mkEnableOption "Orca agent orchestrator server";

    user = lib.mkOption {
      type = lib.types.str;
      default = config.local.profile.username;
      description = "User to run the Orca server as (owns agent credentials).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 6767;
    };

    openFirewall = lib.mkEnableOption "opening the firewall for Orca" // {
      default = true;
    };

    pairingAddress = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Address (Tailscale/LAN hostname or IP) the client dials to pair. Required for remote pairing.";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [ "https://kevinpita.cachix.org" ];
      trusted-public-keys = [
        "kevinpita.cachix.org-1:Cu9UtCDSfDq3/WDnI7N1N/LzAh90SPS+1R+nWao/hz0="
      ];
    };

    systemd.services.orca-server = {
      description = "Orca agent orchestrator server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      wantedBy = [ "multi-user.target" ];

      # Xvfb on PATH so Orca can auto-start a virtual display (:99) for its
      # headless Chromium when no $DISPLAY is set.
      path = [ pkgs.xorg.xvfb ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = "/home/${cfg.user}";
        Restart = "always";
        RestartSec = 5;
        # Orca's bundled Chromium needs these; it never opens a window.
        Environment = [
          "LIBGL_ALWAYS_SOFTWARE=1"
          "ORCA_APPIMAGE_NO_SANDBOX=1"
        ];
      };

      script = lib.concatStringsSep " " (
        [
          "${package}/bin/orca"
          "serve"
          "--port ${toString cfg.port}"
        ]
        ++ lib.optional (cfg.pairingAddress != null) "--pairing-address ${cfg.pairingAddress}"
      );
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
