#!/bin/bash
# Selector de wallpaper — cambia swaybg sin tocar el tema activo.
#
# Uso:
#   wallpaper.sh                 → galería nsxiv de ~/Backgrounds
#   wallpaper.sh <archivo>       → aplica directo (ruta absoluta o nombre dentro de ~/Backgrounds)
#
# Galería nsxiv:
#   - Flechas / hjkl       navegar entre miniaturas
#   - Enter                alternar entre miniaturas y vista grande
#   - Ctrl+X  luego  w     aplicar imagen actual como wallpaper y cerrar
#   - q                    salir sin aplicar
#
# El "Ctrl+X" es el prefijo "command mode" de nsxiv, después se manda al
# key-handler en ~/.config/nsxiv/exec/key-handler.
#
# Nota: al cambiar de tema con SUPER+T, el theme-switcher impone el wallpaper
# del tema y se pierde el override.

WALLPAPERS="$HOME/Backgrounds"

apply() {
    local file="$1"
    [ -f "$file" ] || { notify-send -i error 'Wallpaper' "No existe: $file"; exit 1; }
    pkill -x swaybg 2>/dev/null
    swaybg -i "$file" -m fill >/dev/null 2>&1 &
    disown 2>/dev/null || true
    notify-send -t 1500 -i preferences-desktop-wallpaper 'Wallpaper' "$(basename "$file")"
}

# Modo directo
if [ -n "${1:-}" ]; then
    if [ -f "$1" ]; then
        apply "$1"
    else
        apply "$WALLPAPERS/$1"
    fi
    exit 0
fi

# Modo galería con nsxiv
command -v nsxiv >/dev/null 2>&1 || { notify-send -i error 'Wallpaper' 'nsxiv no instalado'; exit 1; }

shopt -s nullglob nocaseglob
files=("$WALLPAPERS"/*.{png,jpg,jpeg,webp})
shopt -u nullglob nocaseglob

[ ${#files[@]} -eq 0 ] && { notify-send -i error 'Wallpaper' "No hay imágenes en $WALLPAPERS"; exit 1; }

# Carga Xresources (fondo negro de nsxiv). Silencioso si xrdb no está instalado.
command -v xrdb >/dev/null 2>&1 && xrdb -merge ~/.Xresources 2>/dev/null

# Lanza nsxiv en modo galería. La aplicación del wallpaper se delega al
# key-handler en ~/.config/nsxiv/exec/key-handler (tecla Ctrl+w).
nsxiv -t "${files[@]}" 2>/dev/null
