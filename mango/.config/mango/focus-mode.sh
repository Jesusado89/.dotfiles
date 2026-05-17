#!/bin/bash
# Focus mode toggle — oculta waybar + activa DND en swaync. Sin daemon.
# Bind sugerido: SUPER+SHIFT+F.

STATE=/tmp/focus-mode

WAYBAR_ARGS="--config $HOME/.config/waybar/config.jsonc --style $HOME/.config/waybar/style.css"

if [ -f "$STATE" ]; then
    # Salir
    nohup waybar $WAYBAR_ARGS >/dev/null 2>&1 &
    disown 2>/dev/null || true
    makoctl mode -r do-not-disturb 2>/dev/null
    rm -f "$STATE"
    notify-send -t 1500 "Focus mode" "Off"
else
    # Entrar
    pkill -x waybar 2>/dev/null
    makoctl mode -a do-not-disturb 2>/dev/null
    : > "$STATE"
    notify-send -t 1500 "Focus mode" "On"
fi
