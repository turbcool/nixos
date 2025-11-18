#!/usr/bin/env bash
set -euo pipefail

# Name of special workspace (scratchpad)
PAD_NAME="sidepad"

# classes used by kitty (must match windowrule match:initial_class)
NEORG_CLASS="NeorgTerm"
KHAL_CLASS="KhalTerm"

# Helper: check via hyprctl JSON output if a window with given initialClass exists
exists_class() {
  local cls="$1"
  hyprctl clients -j | jq -e --arg c "$cls" '.[] | select(.initialClass == $c)' >/dev/null 2>&1
}

# Spawn Neorg terminal if missing
if ! exists_class "$NEORG_CLASS"; then
  hyprctl dispatch exec, "[workspace special:${PAD_NAME}; float; move (monitor_w*0.8) 0; size (monitor_w*0.2) (monitor_h*0.5); pin]" kitty --class "$NEORG_CLASS" nvim -c "Neorg journal today"
fi

# Spawn Khal terminal if missing
if ! exists_class "$KHAL_CLASS"; then
  hyprctl dispatch exec, "[workspace special:${PAD_NAME}; float; move (monitor_w*0.8) (monitor_h*0.5); size (monitor_w*0.2) (monitor_h*0.5); pin]" kitty --class "$KHAL_CLASS" khal interactive
fi

# Finally toggle the special workspace on/off (will show if hidden, hide if visible)
hyprctl dispatch togglespecialworkspace "$PAD_NAME"
