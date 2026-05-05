{ lib, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    "connect-timeout" = 10;
    "stalled-download-timeout" = 30;
    "download-attempts" = 5;
    "extra-substituters" = lib.mkForce [ ];
    "extra-trusted-public-keys" = lib.mkForce [ ];
  };
}
