#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/catppuccin

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

  printf "^c$black^^b$blue^  "
  printf "^c$blue^^b$bar^ $cpu_val"
}

pkg_updates() {
  # updates=$(doas xbps-install -un | wc -l) # void
  # updates=$(checkupdates | wc -l)   # arch
   updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

  if [ -z "$updates" ]; then
    printf "  ^c$green^^b$bar^  Fully Updated"
  else
    printf "  ^c$green^^b$bar^  $updates"" updates"
  fi
}

#battery() {
#  get_capacity="$(cat /sys/class/power_supply/BAT1/capacity)"
#  printf "^c$blue^ ^b$bar^   $get_capacity"
#}

brightness() {
  printf "^b$blue^^c$black^  "
  printf "^c$blue^^b$bar^ %.0f\n" $(cat /sys/class/backlight/*/brightness)
}

mem() {
  printf "^c$black^^b$blue^  "
  printf "^c$blue^^b$bar^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf "^c$black^^b$blue^ 󰤨 ^d^%s" " ^c$blue^^b$bar^Connected" ;;
	down) printf "^c$black^^b$blue^ 󰤭 ^d^%s" " ^c$blue^^b$bar^Disconnected" ;;
	esac
}

clock() {
	printf "^c$black^^b$darkblue^ 󱑆 "
	printf "^c$blue^^b$bar^ $(date '+%H:%M') "
}

while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$updates $(brightness) $(cpu) $(mem) $(wlan) $(clock)"
done