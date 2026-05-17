#!/bin/bash
# Multi-modal launcher — una sola tecla, 6 modos. Bind sugerido: SUPER+SPACE.
# Solo se ejecuta cuando lo disparas; sin daemon, sin polling.

choice=$(printf '%s\n' \
    " Apps" \
    "󰅍 Clipboard" \
    " Calculator" \
    " Web search" \
    "󰔎 Theme" \
    "󰸉 Wallpaper" \
    "󰐥 Power" \
    | fuzzel --dmenu --prompt "→ ")

[ -z "$choice" ] && exit 0

case "$choice" in
    *Apps*)
        fuzzel
        ;;
    *Clipboard*)
        cliphist list | fuzzel --dmenu | cliphist decode | wl-copy
        ;;
    *Calculator*)
        expr=$(fuzzel --dmenu --prompt " ")
        [ -z "$expr" ] && exit 0
        answer=$(printf '%s\n' "$expr" | bc -l 2>/dev/null)
        if [ -n "$answer" ]; then
            printf '%s' "$answer" | wl-copy
            notify-send "Calc" "$expr = $answer (copiado)"
        else
            notify-send -i error "Calc" "Expresión inválida: $expr"
        fi
        ;;
    *Web*search*)
        query=$(fuzzel --dmenu --prompt " ")
        [ -z "$query" ] && exit 0
        encoded=$(printf '%s' "$query" | sed 's/ /+/g')
        xdg-open "https://duckduckgo.com/?q=$encoded"
        ;;
    *Theme*)
        bash ~/.config/waybar/scripts/theme-switcher.sh menu
        ;;
    *Wallpaper*)
        bash ~/.config/mango/wallpaper.sh
        ;;
    *Power*)
        bash ~/.config/mango/power-menu.sh
        ;;
esac
