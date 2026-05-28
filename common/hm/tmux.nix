{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  vms = [
    { name = "ai-neoplatform"; }
    { name = "ai-skyori"; }
    { name = "ai-proinfoservice"; }
    { name = "ai-timepath"; }
  ];

  mkTmuxDev = pkgs.writeShellScriptBin "dev" ''
    set -eu

    session=$(basename "$(pwd)")

    if tmux has-session -t "$session" 2>/dev/null; then
      exec tmux attach -t "$session"
    fi

    tmux new-session -d -s "$session" -n editor
    tmux send-keys -t "$session":editor 'nvim' Enter

    tmux new-window -t "$session" -n opencode
    tmux send-keys -t "$session":opencode 'opencode' Enter

    tmux new-window -t "$session" -n lazygit
    tmux send-keys -t "$session":lazygit 'lazygit' Enter

    tmux select-window -t "$session":1
    exec tmux attach -t "$session"
  '';

  mkTmuxVms = pkgs.writeShellScriptBin "tmux-vms" ''
    set -eu

    if tmux has-session -t vms 2>/dev/null; then
      exec tmux attach -t vms
    fi

    tmux new-session -d -s vms -n ai-neoplatform
    ${lib.concatStringsSep "\n" (
      lib.imap0 (i: vm: ''
        ${if i > 0 then "tmux new-window -t vms -n ${vm.name}" else ""}
        tmux send-keys -t vms:${vm.name} 'sshpass -f ${
          osConfig.age.secrets."vm-${vm.name}".path
        } ssh ${vm.name}' Enter
      '') vms
    )}

    tmux select-window -t vms:1
    exec tmux attach -t vms
  '';
in
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.bash}/bin/bash";
    clock24 = true;
    keyMode = "vi";
    newSession = true;
    escapeTime = 0;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
    ];

    extraConfig = ''
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on

      set -s extended-keys on
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4

      bind -n M-Left previous-window
      bind -n M-Right next-window

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      set -g status-position bottom
      set -g status-justify centre
      set -g status-style "bg=#1a1b26 fg=#a9b1d6"
      set -g window-status-format " #I:#W "
      set -g window-status-current-format " #I:#W "
      set -g window-status-current-style "bg=#7aa2f7 fg=#1a1b26 bold"
      set -g window-status-style "fg=#565f89"
    '';
  };

  home.packages = [ mkTmuxDev mkTmuxVms ];
}
