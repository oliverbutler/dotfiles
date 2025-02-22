#!/bin/bash

# Set up common nvim options
NVIM_OPTS="--listen /tmp/nvim-server.pipe"

# Check if we're in a config directory
if [[ "$PWD" == "$HOME/.config"* ]]; then
    export GIT_DIR="$HOME/.local/share/yadm/repo.git"
fi

if [ $# -eq 0 ]; then
    # No arguments, open current directory
    command nvim $NVIM_OPTS
else
    # Arguments provided
    command nvim $NVIM_OPTS "$@"
fi
