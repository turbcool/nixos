{ config, pkgs, ... }:

{
  # Enable Remmina
  programs.remmina.enable = true;

  # Copy Remmina configuration files with secrets
  system.activationScripts.remmina-secrets = {
    text = ''
      # Create Remmina config directory
      mkdir -p /home/turb/.config/remmina
      
      # Copy WORK-PC configuration with password from secret
      cat > /home/turb/.config/remmina/work-pc.remmina << EOF
[remmina]
name=WORK-PC
server=10.150.7.42
protocol=RDP
domain=NEOPLATFORM.RU
username=inaidanov
password=$(cat /home/turb/.config/remmina/remmina-work-pc-password)
sound=local
quality=9
window_maximize=1
scale=2
viewmode=4
EOF

      # Copy AutoCam configuration with password from secret
      cat > /home/turb/.config/remmina/autocam.remmina << EOF
[remmina]
name=AutoCam
server=89.169.4.204:57624
protocol=RDP
username=Administrator
password=$(cat /home/turb/.config/remmina/remmina-autocam-password)
window_maximize=1
drive=/home/turb/autocam
EOF

      # Set proper ownership
      chown turb:users /home/turb/.config/remmina/*
      chmod 600 /home/turb/.config/remmina/*
    '';
    deps = [ "agenix-secrets" ];
  };
}