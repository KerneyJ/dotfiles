#!/bin/bash
# Spawn a new Alacritty terminal with the working directory
# of the currently focused terminal

# Get the PID of the active window
ACTIVE_PID=$(hyprctl activewindow -j 2>/dev/null | jq -r '.pid')

# Default to home directory
CWD="$HOME"

if [ -n "$ACTIVE_PID" ] && [ "$ACTIVE_PID" != "null" ]; then
    # Find the shell process (child of terminal)
    SHELL_PID=$(ps -o pid,ppid,comm --ppid "$ACTIVE_PID" 2>/dev/null | awk '/zsh|bash|fish|sh/{print $1; exit}')

    # Get CWD from shell process, or fallback to terminal process
    if [ -n "$SHELL_PID" ]; then
        DETECTED_CWD=$(readlink /proc/"$SHELL_PID"/cwd 2>/dev/null)
    else
        DETECTED_CWD=$(readlink /proc/"$ACTIVE_PID"/cwd 2>/dev/null)
    fi

    # Use detected CWD if valid
    if [ -n "$DETECTED_CWD" ] && [ -d "$DETECTED_CWD" ]; then
        CWD="$DETECTED_CWD"
    fi
fi

# Spawn new Alacritty terminal with the detected working directory
alacritty --working-directory "$CWD" &
