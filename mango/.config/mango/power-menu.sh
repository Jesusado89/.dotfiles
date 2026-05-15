#!/bin/bash
# Power menu basado en fuzzel — no requiere wlogout instalado.
# Acciones: Lock · Logout · Suspend · Reboot · Shutdown.

choice=$(printf '%s\n' \
    "󰌾 Lock" \
    "󰗽 Logout" \
    "󰤄 Suspend" \
    "󰜉 Reboot" \
    "󰐥 Shutdown" \
    | fuzzel --dmenu --prompt "⏻ ")

[ -z "$choice" ] && exit 0

case "$choice" in
    *Lock*)     swaylock ;;
    *Logout*)   pkill -x mango || pkill -x Hyprland || loginctl terminate-user "$USER" ;;
    *Suspend*)  systemctl suspend ;;
    *Reboot*)   systemctl reboot ;;
    *Shutdown*) systemctl poweroff ;;
esac
