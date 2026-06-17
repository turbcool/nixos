{ lib, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    "connect-timeout" = 10;
    "stalled-download-timeout" = 20;
    "download-attempts" = 3;
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
