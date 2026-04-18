{ inputs, pkgs, ... }:

{
  imports = [
    ./cert.nix
    ./git.nix
    ./tmux.nix
    ./llm.nix
  ];
}

