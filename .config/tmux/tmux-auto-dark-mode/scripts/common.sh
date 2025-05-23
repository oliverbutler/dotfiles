#!/usr/bin/env bash

get_tmux_option() {
    # Read tmux option with default value.
    local option="$1"
    local default_value="$2"
    local option_value=$(tmux show-option -gqv "$option")
    if [ -z "$option_value" ]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

set_tmux_option() {
    # Set value to option.
    local option="$1"
    local value="$2"
    tmux set-option -gq "$option" "$value"
}

set_status_right_value() {
    # Store current value of status-right.
    local status_right_value="$(get_tmux_option "status-right" "")"

    # If an argument is given, source this file.
    if [[ $# -eq 1 ]] ; then
        # Load status line config.
        tmux source-file "$1"
        # Get new status right value.
        status_right_value="$(get_tmux_option "status-right" "")"
        # Add Continuum command.
        status_right_value="${continuum_command}${status_right_value}"
        # Check that the Continuum command is not already added.
        # if ! [[ "$status_right_value" == *continuum_save.sh* ]] ; then
        #     # Prepend Continuum command to the status line.
        #     new_status_right_value="${continuum_command}${status_right_value}"
        # fi
    fi

    # Add auto dark mode command.
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    local adm_command="#($CURRENT_DIR/auto-dark-mode.sh)"
    # Check that the command is not already added.
    if ! [[ "$status_right_value" == *"$adm_command"* ]] ; then
        # Prepend the command to the status line.
        status_right_value="${adm_command}${status_right_value}"
    fi

    # Set status-right value.
    set_tmux_option "status-right" "$status_right_value"
}



broadcast_nvim_theme_change() {
    local mode="$1" # "dark" or "light"
    for sock in /tmp/nvim-server*.pipe; do
        if [ -e "$sock" ]; then
            nvim --server "$sock" --remote-send "<Esc>:set background=$mode<CR>" 2>/dev/null
        fi
    done
}

set_dark_mode() {
    tmux set-environment -g NVIM_THEME dark
    broadcast_nvim_theme_change dark

    tmux source-file ~/.config/tmux/reset-theme.conf
    tmux source-file ~/.config/tmux/dark-status.conf
    set_status_right_value "$(get_tmux_option "@adm-status-dark" "")"
    set_tmux_option "@adm-current-mode" "dark"
}

set_light_mode() {
    tmux set-environment -g NVIM_THEME light
    broadcast_nvim_theme_change light

    tmux source-file ~/.config/tmux/reset-theme.conf
    tmux source-file ~/.config/tmux/light-status.conf
    set_status_right_value "$(get_tmux_option "@adm-status-light" "")"
    set_tmux_option "@adm-current-mode" "light"
}
