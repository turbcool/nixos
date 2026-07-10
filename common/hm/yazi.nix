{ inputs, ... }:

{
  programs.yazi = {
    enable = true;

    # `zz` runs the standard cwd-on-exit wrapper: open yazi, and on quit the
    # shell cds into whatever directory you ended in (renamed from the
    # default `yy`).
    shellWrapperName = "zz";
    enableZshIntegration = true;

    # VS Code "Dark Modern" flavor — matches the VS Code default dark theme.
    # To switch variant, point the input (flake.nix) at another 956MB repo
    # (vscode-dark-plus / vscode-light-modern / vscode-light-plus) and update
    # the attr key + theme.flavor.dark below to match.
    flavors.vscode-dark-modern = inputs.vscode-yazi;
    theme.flavor.dark = "vscode-dark-modern";
  };
}
