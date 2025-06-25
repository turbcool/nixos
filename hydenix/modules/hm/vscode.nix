{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        ms-dotnettools.csdevkit
        ms-dotnettools.csharp
        ms-dotnettools.vscode-dotnet-runtime
        ms-vscode-remote.remote-containers
      ];
      userSettings = {
        "editor.fontFamily" = "CaskaydiaCove Nerd Font Mono";
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "omnisharp.useModernNet" = true;
        "git.enableSmartCommit" = true;
        "editor.minimap.enabled" = false;
        "workbench.colorTheme": "Kanagawa Vague Dark";
      };
    };     
  };
  xdg.configFile = {
    # --enable-ozone
    # --enable-features=UseOzonePlatform
    "code-flags.conf".text = ''
      --ozone-platform=wayland
      --ozone-platform-hint=auto
      --enable-features=WaylandWindowDecorations,WaylandLinuxDrmSyncobj
    '';
  };
  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];
}
