#!/bin/sh
pulseaudio --start
xinput set-prop 14 338 1 # tap clicking
xinput set-prop 14 316 1 # natural scrolling
# xinput set-prop 15 338 1 # tap clicking
# xinput set-prop 15 317 1 # natural scrolling
picom -b --experimental-backends
nitrogen --restore
