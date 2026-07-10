{ lib, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Tolerate slow/throttled binary-cache edges: raise the stall ceiling and
    # retry harder so a transient blip doesn't fail a whole `nixos-rebuild`.
    # (Throttled cachix transfers are handled separately via the nix-daemon
    # proxy in wsl/configuration.nix; these values are the backstop.)
    "connect-timeout" = 30;
    "stalled-download-timeout" = 60;
    "download-attempts" = 5;
    substituters = [
      "https://cache.nixos.org"
      "https://claude-code.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };
}
