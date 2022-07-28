#!/bin/bash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/catppuccin

## Files and Data
PREV_TOTAL=0
PREV_IDLE=0
cpuFile="/tmp/.cpu_usage"

cpu() {
  #cpu_val=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')

## Get CPU usage
get_cpu() {
	if [[ -f "${cpuFile}" ]]; then
		fileCont=$(cat "${cpuFile}")
		PREV_TOTAL=$(echo "${fileCont}" | head -n 1)
		PREV_IDLE=$(echo "${fileCont}" | tail -n 1)
	fi

	CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
	unset CPU[0]                          # Discard the "cpu" prefix.
	IDLE=${CPU[4]}                        # Get the idle CPU time.

	# Calculate the total CPU time.
	TOTAL=0

	for VALUE in "${CPU[@]:0:4}"; do
		let "TOTAL=$TOTAL+$VALUE"
	done

	if [[ "${PREV_TOTAL}" != "" ]] && [[ "${PREV_IDLE}" != "" ]]; then
		# Calculate the CPU usage since we last checked.
		let "DIFF_IDLE=$IDLE-$PREV_IDLE"
		let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
		let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
		echo "${DIFF_USAGE}"
	else
		echo "?"
	fi

	# Remember the total and idle CPU times for the next check.
	echo "${TOTAL}" > "${cpuFile}"
	echo "${IDLE}" >> "${cpuFile}"
}
  printf "^c$black^^b$blue^  "
  echo "^c$blue^^b$bar^" $(get_cpu)%
}

pkg_updates() {
  # updates=$(doas xbps-install -un | wc -l) # void
  # updates=$(checkupdates | wc -l)   # arch
   updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

  if [ "$updates" == 0 ]; then
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
  echo "^c$blue^^b$bar^" $(($(cat /sys/class/backlight/*/brightness)*10))%
}

volume() {
  printf "^b$blue^^c$black^  "
  printf "^c$blue^^b$bar^ $(amixer get Master | awk '$0~/%/{print $4}' | tr -d '[%]')%%"
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

  sleep 1 && xsetroot -name "$updates $(brightness) $(volume) $(cpu) $(mem) $(wlan) $(clock)"
done