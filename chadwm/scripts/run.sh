#!/bin/bash

killall dunst xfce4-power-manager picom redshift feh flameshot

xrdb merge ~/.Xresources
brightnessctl set 10 &
feh --bg-fill ~/Pictures/wallpapers/javascript.jpg &
#xset r rate 200 50 &
#picom --experimental-backends &
dunst &
notify-send "Welcome back $USER!" &
xfce4-power-manager &
nm-applet &
xfce4-clipman &
flameshot &
redshift &
ksuperkey -e 'Super_L=Alt_L|F1'

~/.config/chadwm/scripts/bar.sh &
while type dwm >/dev/null; do dwm && continue || break; done