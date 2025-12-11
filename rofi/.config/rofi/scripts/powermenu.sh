#!/usr/bin/env bash

#******************************************************************************
# ROFI POWER MENU SCRIPT
# A simple power menu using rofi
#******************************************************************************

# Options
shutdown="⏻ Shutdown"
reboot=" Reboot"
lock=" Lock"
suspend="⏾ Suspend"
logout="󰍃 Logout"

# Get user selection
selected=$(echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | \
    rofi -dmenu \
         -theme ~/.config/rofi/powermenu.rasi \
         -p "Power" \
         -selected-row 0)

# Execute based on selection
case $selected in
    "$shutdown")
        systemctl poweroff
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$lock")
        slock
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$logout")
        pkill -SIGTERM dwm
        ;;
esac
