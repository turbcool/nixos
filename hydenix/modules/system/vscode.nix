{ pkgs, ... }:
let
  dotnet-full =
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      runtime_8_0
      aspnetcore_8_0
    ];

  deps = (
    ps:
    with ps;
    [
      zlib
      openssl.dev
      pkg-config
      stdenv.cc
      cmake
      mono
      msbuild
    ]
    ++ [ dotnet-full ]
  );
in
{
  programs.vscode = {
    enable = true;
    package =
      (pkgs.vscode.overrideAttrs (prevAttrs: {
        nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ pkgs.makeWrapper ];
        postFixup =
          prevAttrs.postFixup
          + ''
            wrapProgram $out/bin/code \
              --set DOTNET_ROOT "${dotnet-full}" \
              --prefix PATH : "~/.dotnet/tools"
          '';
      })).fhsWithPackages
        (ps: deps ps);
    extensions = [ ];
  };
}
