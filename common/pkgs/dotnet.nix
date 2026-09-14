{ config, lib, pkgs, ... }:

let
  cfg = config.local.pkgs.dotnet;
  # 3.1 and 6.0 are EOL; nixpkgs drops 3.1 and marks 6.0 insecure.
  # Fetch the final official Microsoft SDK tarballs to run legacy apps.
  mkTarballSdk = version: hash: pkgs.stdenvNoCC.mkDerivation {
    pname = "dotnet-sdk-${lib.versions.majorMinor version}";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://dotnetcli.azureedge.net/dotnet/Sdk/${version}/dotnet-sdk-${version}-linux-x64.tar.gz";
      inherit hash;
    };
    installPhase = ''
      mkdir -p "$out/share/dotnet"
      tar xzf "$src" -C "$out/share/dotnet"
    '';
    passthru = {
      inherit version;
      packages = [ ];
      targetPackages = { };
    };
    meta = {
      mainProgram = "dotnet";
      homepage = "https://dotnet.microsoft.com/";
      license = pkgs.lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
    };
  };
  dotnet-sdk-3_1 = mkTarballSdk "3.1.426" "sha256-zOSBwFTDMa1X4m5dMmmTsiCaYbTfZhGOe66HjQn1HcE=";
  dotnet-sdk-6_0 = mkTarballSdk "6.0.428" "sha256-my+bkeKGd7WOR9NKHZ4qiPWXrx9qzUR2Sjq8Lxus3Io=";
  dotnet-sdk =
    (with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      dotnet-sdk-3_1
      dotnet-sdk-6_0
      sdk_10_0
    ]);
  dotnetRoot = "${dotnet-sdk}/share/dotnet";
in
{
  options.local.pkgs.dotnet.enable = (lib.mkEnableOption ".NET packages") // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dotnet-sdk
      roslyn-ls
    ];

    environment.sessionVariables = {
      DOTNET_ROOT = dotnetRoot;
    };
  };
}
