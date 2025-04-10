#!/bin/bash

# Find a unique socket path
i=1
SOCKET="/tmp/nvim-server.pipe"
while [[ -e "$SOCKET" ]]; do
    SOCKET="/tmp/nvim-server-$i.pipe"
    ((i++))
done

export NVIM_LISTEN_ADDRESS="$SOCKET"
NVIM_OPTS="--listen $SOCKET"

# Set up GIT_DIR if in config dir
if [[ "$PWD" == "$HOME/.config"* ]]; then
    export GIT_DIR="$HOME/.local/share/yadm/repo.git"
fi

# Launch nvim
if [ $# -eq 0 ]; then
    command nvim $NVIM_OPTS
else
    command nvim $NVIM_OPTS "$@"
fi
