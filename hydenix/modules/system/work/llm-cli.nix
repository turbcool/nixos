{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    #inputs.nix-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.crush
  ];
}
