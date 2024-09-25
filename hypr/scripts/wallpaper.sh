#!/bin/bash

WP="$HOME/.config/hypr/wallpaper"
wallpapers=("evening-sky.png" "mountain.png" "train.jpg")
wplen=${#wallpapers[@]}
current=$(swww query | awk -F"image: " '{print $2}')
index=0

for i in ${wallpapers[@]}
do
	if [ "\"$i\"" == $current ]; then
		break
	fi
	((index += 1))
done

if [ $wplen -eq $((index + 1)) ]; then
	swww img -t any --transition-bezier 0.0,0.0,1.0,1.0 --transition-fps 144 --transition-duration 2 --transition-step 20 $WP/${wallpapers[0]}
else
	swww img -t any --transition-bezier 0.0,0.0,1.0,1.0 --transition-fps 144 --transition-duration 2 --transition-step 20 $WP/${wallpapers[$((index + 1))]}
fi
