#!/usr/bin/env bash

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS theme detection
    theme=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
    if [[ -z "$theme" ]]; then
        # No output means light theme
        echo "latte"
    else
        # "Dark" output means dark theme
        echo "mocha"
    fi
else
    # Linux desktop environment detection
    if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
        theme=$(gsettings get org.gnome.desktop.interface color-scheme)
        if [[ $theme == *"light"* ]]; then
            echo "latte"
        else
            echo "mocha"
        fi
    elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
        theme=$(kreadconfig5 --group "General" --key "ColorScheme")
        if [[ $theme == *"Light"* ]]; then
            echo "latte"
        else
            echo "mocha"
        fi
    else
        # Default to dark theme if we can't detect
        echo "mocha"
    fi
fi

