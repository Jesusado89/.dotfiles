#!/bin/bash
# Battery watcher — notifica niveles bajos y suspende en crítico.
# Lanzado por mango via exec-once. Single-instance, polling cada 60s.
#
# Niveles:
#   ≤ 20%   → notify-send normal (una sola vez por bajada)
#   ≤ 10%   → notify-send urgente
#   ≤  5%   → systemctl suspend (solo si NO está cargando)

BAT_PATH=/sys/class/power_supply/BAT0
NOTIFIED_LOW=0
NOTIFIED_CRIT=0

# Evita múltiples instancias
pgrep -fx "bash $HOME/.config/mango/battery-watch.sh" | grep -v $$ | xargs -r kill 2>/dev/null

while true; do
    [ -d "$BAT_PATH" ] || { sleep 60; continue; }

    capacity=$(cat "$BAT_PATH/capacity" 2>/dev/null)
    status=$(cat "$BAT_PATH/status" 2>/dev/null)

    [ -z "$capacity" ] && { sleep 60; continue; }

    # Si está cargando, reseteamos flags y dormimos
    if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
        NOTIFIED_LOW=0
        NOTIFIED_CRIT=0
        sleep 60
        continue
    fi

    # 5% crítico → suspend
    if [ "$capacity" -le 5 ]; then
        notify-send -u critical -t 5000 -i battery-caution \
            "Batería crítica" "Suspendiendo en 10s para evitar apagón."
        sleep 10
        # Re-check para evitar suspend si conectó cable
        new_status=$(cat "$BAT_PATH/status" 2>/dev/null)
        if [ "$new_status" != "Charging" ]; then
            systemctl suspend
        fi
        sleep 60
        continue
    fi

    # 10% urgente
    if [ "$capacity" -le 10 ] && [ "$NOTIFIED_CRIT" -eq 0 ]; then
        notify-send -u critical -t 0 -i battery-caution \
            "Batería muy baja" "${capacity}% — conecta el cargador YA."
        NOTIFIED_CRIT=1
    fi

    # 20% aviso
    if [ "$capacity" -le 20 ] && [ "$NOTIFIED_LOW" -eq 0 ]; then
        notify-send -u normal -t 5000 -i battery-low \
            "Batería baja" "${capacity}% restante."
        NOTIFIED_LOW=1
    fi

    # Resetea flag de bajo si subió por encima de umbral (ej. lo conectaron brevemente)
    [ "$capacity" -gt 25 ] && NOTIFIED_LOW=0
    [ "$capacity" -gt 15 ] && NOTIFIED_CRIT=0

    sleep 60
done
