#!/usr/bin/env bash
# Click izquierdo en módulo USB de waybar.
# Si hay alguna partición USB montada, abre Nemo en ella.
# Si no, intenta montar todas las disponibles.

set -euo pipefail

mount_point=$(lsblk -J -o NAME,MOUNTPOINT,RM,TRAN \
  | jq -r '
    [ .blockdevices[]
      | select(.tran == "usb" or .rm == true)
      | (.children // [.])[]
      | .mountpoint // empty
    ] | first // empty
  ')

if [[ -n "$mount_point" ]]; then
  exec nemo "$mount_point"
fi

# No hay nada montado: intentar montar con udiskie
if command -v udiskie-mount >/dev/null 2>&1; then
  udiskie-mount -a >/dev/null 2>&1 || true
  # Reintentar abrir Nemo después
  sleep 1
  mount_point=$(lsblk -J -o NAME,MOUNTPOINT,RM,TRAN \
    | jq -r '
      [ .blockdevices[]
        | select(.tran == "usb" or .rm == true)
        | (.children // [.])[]
        | .mountpoint // empty
      ] | first // empty
    ')
  [[ -n "$mount_point" ]] && exec nemo "$mount_point"
fi

notify-send -t 3000 "USB" "No hay dispositivos USB para montar"
