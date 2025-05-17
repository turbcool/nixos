{ pkgs, ... }:
let
  dotnet-full =
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_9_0
    ];
in
{
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-dotnettools.csdevkit
      ms-dotnettools.csharp
      ms-dotnettools.vscode-dotnet-runtime
    ];
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
