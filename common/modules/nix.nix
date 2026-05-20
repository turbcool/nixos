{ lib, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    "connect-timeout" = 10;
    "stalled-download-timeout" = 30;
    "download-attempts" = 5;
    substituters = [ "https://claude-code.cachix.org" ];
    trusted-public-keys = [ "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" ];
  };
}
