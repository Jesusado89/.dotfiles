#!/bin/bash
# Focus mode toggle — oculta waybar + activa DND en swaync. Sin daemon.
# Bind sugerido: SUPER+SHIFT+F.

STATE=/tmp/focus-mode

if [ -f "$STATE" ]; then
    # Salir
    nohup waybar >/dev/null 2>&1 &
    disown 2>/dev/null || true
    swaync-client -df 2>/dev/null
    rm -f "$STATE"
    notify-send -t 1500 "Focus mode" "Off"
else
    # Entrar
    pkill -x waybar 2>/dev/null
    swaync-client -dn 2>/dev/null
    : > "$STATE"
    notify-send -t 1500 "Focus mode" "On"
fi
