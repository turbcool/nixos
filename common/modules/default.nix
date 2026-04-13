{ inputs, pkgs, ... }:

{
  imports = [
    ./cert.nix
    ./git.nix
    ./llm.nix
    ./tmux.nix
  ];
}

