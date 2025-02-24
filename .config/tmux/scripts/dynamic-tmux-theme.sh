#!/bin/bash

# Make sure check-theme.sh outputs the correct flavor (e.g., "latte", "mocha", etc.)
theme_flavor=$(~/.config/tmux/scripts/check-theme.sh)

# Write to a temporary tmux configuration file
cat <<EOF > ~/.config/tmux/dynamic-config.tmux
set -g @catppuccin_flavor "$theme_flavor"
set -g @catppuccin_window_status_style "rounded"
EOF
