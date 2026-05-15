#!/bin/bash
# Theme switcher — cambia waybar CSS + wallpaper en una sola operación.
#
# Uso:
#   theme-switcher.sh                  → menú gráfico (fuzzel)
#   theme-switcher.sh rotate           → siguiente tema en la lista
#   theme-switcher.sh current          → imprime el tema activo
#   theme-switcher.sh list             → imprime todos los temas
#   theme-switcher.sh menu-tty         → menú en terminal (fallback)
#   theme-switcher.sh <theme-name>     → cambiar directo, e.g. "dracula"
#
# Para re-mapear un tema con otro wallpaper, edita la tabla THEMES de abajo:
# "key" => "Nombre Bonito|wallpaper_filename"

set -u

CONFIG_DIR="$HOME/.config/waybar"
STYLE_FILE="$CONFIG_DIR/style.css"
WALLPAPERS_DIR="$HOME/Backgrounds"

# theme-key → "Display Name|wallpaper-file"
declare -A THEMES=(
    [catppuccin-mocha]="Catppuccin Mocha|22.jpg"
    [tokyo-night]="Tokyo Night|12.png"
    [rose-pine]="Rosé Pine|14.png"
    [dracula]="Dracula|24.png"
    [nord]="Nord|11.png"
    [gruvbox-dark]="Gruvbox Dark|21.jpg"
    [everforest]="Everforest|26.jpg"
    [hackerman]="Hackerman|19.png"
    [aurora]="Aurora|18.jpg"
    [ember]="Ember|02.jpg"
    [ethereal]="Ethereal|16.png"
    [kanagawa]="Kanagawa|27.jpg"
    [lumon]="Lumon|23.jpg"
    [matte-black]="Matte Black|25.jpg"
    [miasma]="Miasma|03.jpg"
    [obsidian]="Obsidian|10.png"
    [osaka-jade]="Osaka Jade|26.jpg"
    [retro-82]="Retro 82|04.png"
    [ristretto]="Ristretto|01.jpg"
    [absolute-black]="Absolute Black|25.jpg"
    [vantablack]="Vantablack|20.png"
)

# Orden para rotate / menú
THEME_ORDER=(
    catppuccin-mocha tokyo-night rose-pine dracula nord
    gruvbox-dark everforest hackerman aurora ember
    ethereal kanagawa lumon matte-black miasma
    obsidian osaka-jade retro-82 ristretto absolute-black vantablack
)

get_current_theme() {
    grep -E '^@import' "$STYLE_FILE" 2>/dev/null \
        | grep -v '/\*' | head -1 \
        | sed -E 's|@import "(.*)\.css";|\1|'
}

apply_wallpaper() {
    local wp="$1"
    [ -z "$wp" ] && return 0
    [ -f "$WALLPAPERS_DIR/$wp" ] || return 0
    pkill -x swaybg 2>/dev/null
    sleep 0.1
    swaybg -i "$WALLPAPERS_DIR/$wp" -m fill >/dev/null 2>&1 &
    disown 2>/dev/null || true
}

reload_waybar() {
    # SIGUSR2 = reload config without restart. Fall back to launch if not running.
    pkill -SIGUSR2 waybar 2>/dev/null || waybar >/dev/null 2>&1 &
    disown 2>/dev/null || true
}

apply_mango_colors() {
    # Lee colores desde el CSS del tema y los aplica al config.conf de mango.
    # Usa iris (accent) → focuscolor, muted (dim) → bordercolor, love (red) → urgentcolor.
    local css="$1"
    local mango_conf="$HOME/.config/mango/config.conf"
    [ -f "$css" ] || return 0
    [ -f "$mango_conf" ] || return 0

    local iris muted love
    iris=$(grep  -E '^@define-color iris '  "$css" | grep -oE '#[0-9a-fA-F]{6}' | head -1 | tr -d '#')
    muted=$(grep -E '^@define-color muted ' "$css" | grep -oE '#[0-9a-fA-F]{6}' | head -1 | tr -d '#')
    love=$(grep  -E '^@define-color love '  "$css" | grep -oE '#[0-9a-fA-F]{6}' | head -1 | tr -d '#')

    [ -z "$iris" ] || [ -z "$muted" ] || [ -z "$love" ] && return 0

    sed -i \
        -e "s|^focuscolor=.*|focuscolor=0x${iris}ff|" \
        -e "s|^bordercolor=.*|bordercolor=0x${muted}ff|" \
        -e "s|^urgentcolor=.*|urgentcolor=0x${love}ff|" \
        "$mango_conf"

    # Si mango está corriendo, recargar
    pgrep -x mango >/dev/null 2>&1 && mmsg -d reload_config 2>/dev/null
}

apply_theme() {
    local key="$1"
    local meta="${THEMES[$key]:-}"
    if [ -z "$meta" ]; then
        echo "Tema desconocido: $key"
        echo "Disponibles: ${!THEMES[*]}"
        return 1
    fi
    if [ ! -f "$CONFIG_DIR/$key.css" ]; then
        echo "Falta $CONFIG_DIR/$key.css"
        return 1
    fi

    local name="${meta%%|*}"
    local wp="${meta#*|}"

    sed -i "s|^@import \".*\";|@import \"$key.css\";|" "$STYLE_FILE"
    reload_waybar
    apply_wallpaper "$wp"
    apply_mango_colors "$CONFIG_DIR/$key.css"
    notify-send -t 2000 "Theme" "$name"
}

rotate_theme() {
    local current n=${#THEME_ORDER[@]}
    current=$(get_current_theme)
    for i in "${!THEME_ORDER[@]}"; do
        if [ "${THEME_ORDER[$i]}" = "$current" ]; then
            apply_theme "${THEME_ORDER[$(( (i + 1) % n ))]}"
            return
        fi
    done
    apply_theme "${THEME_ORDER[0]}"
}

show_menu_fuzzel() {
    command -v fuzzel >/dev/null 2>&1 || { show_menu_tty; return; }
    local choice key
    choice=$(
        for key in "${THEME_ORDER[@]}"; do
            printf '%s :: %s\n' "${THEMES[$key]%%|*}" "$key"
        done | fuzzel --dmenu --prompt 'Theme: '
    )
    [ -z "$choice" ] && return
    key="${choice##* :: }"
    apply_theme "$key"
}

show_menu_tty() {
    local current i=1
    current=$(get_current_theme)
    printf 'Tema actual: %s\n\n' "$current"
    for key in "${THEME_ORDER[@]}"; do
        local mark=""; [ "$key" = "$current" ] && mark=" ✓"
        printf '  %2d. %s%s\n' "$i" "${THEMES[$key]%%|*}" "$mark"
        i=$((i+1))
    done
    printf '\nSelecciona (1-%d): ' "${#THEME_ORDER[@]}"
    read -r choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#THEME_ORDER[@]} ]; then
        apply_theme "${THEME_ORDER[$((choice-1))]}"
    fi
}

case "${1:-menu}" in
    rotate)   rotate_theme ;;
    menu)     show_menu_fuzzel ;;
    menu-tty) show_menu_tty ;;
    current)  get_current_theme ;;
    list)     printf '%s\n' "${THEME_ORDER[@]}" ;;
    *)
        if [ -n "${THEMES[$1]:-}" ]; then
            apply_theme "$1"
        else
            cat <<EOF
Uso: $0 {rotate|menu|menu-tty|current|list|<theme-name>}

Themes disponibles:
$(printf '  %s\n' "${THEME_ORDER[@]}")
EOF
            exit 1
        fi
        ;;
esac
