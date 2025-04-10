#!/usr/bin/env bash
# Simplified tmux theme switcher

# Helper function to set tmux options
tmux_set() {
    tmux set-option -gq "$1" "$2"
}

# Get theme from tmux option
theme=$(tmux show -gqv "@tmux_power_theme")
if [ -z "$theme" ]; then
    theme="mocha"  # Default to dark theme
fi

# Set colors based on theme
case $theme in
    'mocha' )
        # Dark theme
        TC='#b4befe'  # accent color (lavender)
        G0='#1e1e2e'  # background
        G1='#313244'  # surface0
        G2='#45475a'  # surface1
        G3='#585b70'  # surface2
        G4='#ffffff'  # text color
        ;;
    'latte' )
        # Light theme
        TC='#7287fd'  # accent color (lavender)
        G0='#eff1f5'  # background
        G1='#ccd0da'  # surface0
        G2='#bcc0cc'  # surface1
        G3='#acb0be'  # surface2
        G4='#1e1e2e'  # text color
        ;;
esac

# Status bar basic settings
tmux_set status-interval 1
tmux_set status on
tmux_set status-bg "$G0"
tmux_set status-fg "$G4"

# Left status (empty for minimal look)
tmux_set status-left ""
tmux_set status-left-length 50

# Right status (time and date)
tmux_set status-right "#[fg=$TC,bg=$G2] %H:%M:%S #[fg=$G0,bg=$TC] %Y-%m-%d "
tmux_set status-right-length 50

tmux_set window-status-format "#[fg=$G0,bg=$G0]#[fg=$TC,bg=$G1,nobold] #I #[fg=white,bg=$G1]#W #[fg=$G4,bg=$G0,nobold]"
tmux_set window-status-current-format "#[fg=$G0,bg=$G0]#[fg=$TC,bg=$G0,bold]#[fg=$G0,bg=$TC,bold]#I #[fg=$G4,bg=$G2,bold] #W #[fg=$G4,bg=$G0,nobold]#[fg=$G2]"

# Window status style
tmux_set window-status-style "fg=$TC,bg=$G0,none"
tmux_set window-status-current-style "fg=$G0,bg=$TC,bold"
tmux_set window-status-separator " "

# Pane borders
tmux_set pane-border-style "fg=$G3,bg=default"
tmux_set pane-active-border-style "fg=$TC,bg=default"

# Messages
tmux_set message-style "fg=$TC,bg=$G0"
tmux_set message-command-style "fg=$TC,bg=$G0"

# Copy mode
tmux_set mode-style "bg=$TC,fg=$G4"
