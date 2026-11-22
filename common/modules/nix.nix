{ lib, ... }:

{
  # gtk2 is marked broken in the pinned nixpkgs; onlyoffice still needs it.
  nixpkgs.config = lib.mkDefault { problems.handlers."gtk+".broken = "warn"; };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Tolerate slow/throttled binary-cache edges: abandon an unreachable cache
    # sooner, retry harder, and never fail a whole `nixos-rebuild` over one --
    # fall back to building locally. The cachix CDN is intermittently slow from
    # this network; wsl additionally proxies the daemon (wsl/configuration.nix),
    # these values are the backstop everywhere else.
    "connect-timeout" = 15;
    "stalled-download-timeout" = 60;
    "download-attempts" = 10;
    fallback = true;
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
