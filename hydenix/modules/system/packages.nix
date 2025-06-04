# Package definitions and program configurations
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.telegram-desktop
    pkgs.yt-dlp
    pkgs.kdePackages.ark
    pkgs.easyeffects
    pkgs.cudatoolkit
    (python3.withPackages (ps: [
      ps.pytorchWithCuda
      # ps.torchvisionWithCuda # Uncomment if torchvision is needed
    ]))
  ];
}
