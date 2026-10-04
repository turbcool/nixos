{ ... }:

{
  imports = [
    ../../../common/hm/default.nix

    # Reused verbatim from the hydenix host — none of these touch a hydenix
    # option. firefox.nix guards its one hydenix line on `config ? hydenix`.
    ../../../hydenix/modules/hm/firefox.nix
    ../../../hydenix/modules/hm/helium.nix
    ../../../hydenix/modules/hm/remmina.nix
    ../../../hydenix/modules/hm/vscode.nix
    ../../../hydenix/modules/hm/wolf.nix

    ./kitty.nix
  ];
}
