#!/usr/bin/env bash
set -euo pipefail

PAD_NAME="sidepad"
NEORG_CLASS="NeorgTerm"
KHAL_CLASS="KhalTerm"

# Try to detect hyprctl client by initialClass using jq (recommended)
has_client_with_initialclass_jq() {
  local cls="$1"
  hyprctl clients -j 2>/dev/null | jq -e --arg C "$cls" '.[] | select(.initialClass == $C)' >/dev/null 2>&1
}

# Fallback detection (if jq missing or hyprctl JSON doesn't have initialClass)
has_client_with_initialclass_grep() {
  local cls="$1"
  # Look for the class string anywhere in hyprctl clients -j output
  hyprctl clients -j 2>/dev/null | grep -F --quiet "$cls"
}

# Preferred detection: use jq if present
detect_client() {
  local cls="$1"
  if command -v jq >/dev/null 2>&1; then
    has_client_with_initialclass_jq "$cls" && return 0 || return 1
  else
    has_client_with_initialclass_grep "$cls" && return 0 || return 1
  fi
}

# Spawn Neorg terminal top-right (20% width, top half)
#if ! detect_client "$NEORG_CLASS"; then
  #hyprctl dispatch exec "[workspace special:${PAD_NAME} silent; float; pin; move 80% 0; size 20% 50%; noanim]" \
  #  kitty --class "$NEORG_CLASS" sh -c "nvim -c 'Neorg journal today'"
#fi

# Spawn Khal terminal bottom-right (20% width, bottom half)
if ! detect_client "$KHAL_CLASS"; then
  hyprctl dispatch exec "kitty sh -c \"khal interactive\""
  #hyprctl dispatch exec "[workspace special:${PAD_NAME} silent; float; pin; move 80% 50%; size 20% 50%; noanim]" \
  #  kitty --class "$KHAL_CLASS" sh -c "khal interactive"
fi

# Toggle the special workspace visible/hidden (this will show if hidden, hide if visible)
#hyprctl dispatch togglespecialworkspace "$PAD_NAME"
