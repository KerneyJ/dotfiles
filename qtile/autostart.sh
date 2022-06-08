#!/bin/sh
pulseaudio --start
xinput set-prop 14 338 1 # tap clicking
xinput set-prop 14 317 1 # natural scrolling
picom -b --experimental-backends
nitrogen --restore
