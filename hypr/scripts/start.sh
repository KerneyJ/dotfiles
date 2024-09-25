#!/bin/bash
rm $XDG_RUNTIME_DIR/swww.socket
waybar &
swww init >> $HOME/swww.log 2>&1
swww img $HOME/.config/hypr/wallpaper/evening-sky.png
moc &
nm-applet &
