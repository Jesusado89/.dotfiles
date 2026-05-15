#!/bin/bash
# Unified screenshot tool. Usage: screenshot.sh {full|sel|full-save|sel-save}
#
# - full       → captura pantalla entera al portapapeles
# - sel        → seleccionas una región (slurp) y va al portapapeles
# - full-save  → captura pantalla y guarda en ~/Screenshots/
# - sel-save   → seleccionas región y guarda en ~/Screenshots/
#
# En modos "sel": si cancelas la selección con Esc, el script termina silencioso.

mkdir -p ~/Screenshots

case "${1:-full}" in
    full)
        if grim - | wl-copy; then
            notify-send -i camera 'Screenshot' 'Pantalla completa copiada al portapapeles'
        fi
        ;;
    sel)
        region=$(slurp) || exit 0
        if grim -g "$region" - | wl-copy; then
            notify-send -i camera 'Screenshot' 'Selección copiada al portapapeles'
        fi
        ;;
    full-save)
        f=~/Screenshots/$(date +%Y%m%d_%H%M%S).png
        if grim "$f"; then
            notify-send -i camera 'Screenshot' "Guardado: $f"
        fi
        ;;
    sel-save)
        region=$(slurp) || exit 0
        f=~/Screenshots/$(date +%Y%m%d_%H%M%S)_sel.png
        if grim -g "$region" "$f"; then
            notify-send -i camera 'Screenshot' "Guardado: $f"
        fi
        ;;
    *)
        echo "Uso: $0 {full|sel|full-save|sel-save}"
        exit 1
        ;;
esac
