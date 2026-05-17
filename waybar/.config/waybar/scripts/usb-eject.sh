#!/usr/bin/env bash
# Click derecho en módulo USB: desmonta y avisa si es seguro retirar.

set -euo pipefail

ICON="drive-removable-media"

if ! command -v udiskie-umount >/dev/null 2>&1; then
  notify-send -u critical -t 3000 -i "$ICON" "USB" "udiskie no está instalado"
  exit 1
fi

# Recolecta mountpoints de dispositivos USB/removibles
mountpoints=$(lsblk -J -o NAME,MOUNTPOINT,RM,TRAN \
  | jq -r '
    .blockdevices[]
    | select(.tran == "usb" or .rm == true)
    | (.children // [.])[]
    | .mountpoint // empty
  ' | grep -v '^$' || true)

if [[ -z "$mountpoints" ]]; then
  notify-send -t 4000 -i "$ICON" \
    "✓ USB listo" "No hay particiones montadas. Puedes retirarlo."
  exit 0
fi

# Detecta si algún mountpoint tiene procesos abiertos
busy_lines=""
while IFS= read -r mp; do
  if fuser -s -m "$mp" 2>/dev/null; then
    procs=$(fuser -m "$mp" 2>/dev/null \
      | tr -s ' ' '\n' \
      | grep -E '^[0-9]+$' \
      | xargs -r -n1 ps -o comm= -p 2>/dev/null \
      | sort -u \
      | paste -sd', ' -)
    [[ -z "$procs" ]] && procs="(proceso desconocido)"
    busy_lines+="• ${mp}: ${procs}"$'\n'
  fi
done <<< "$mountpoints"

if [[ -n "$busy_lines" ]]; then
  notify-send -u critical -t 7000 -i "$ICON" \
    "⚠ USB en uso — no lo retires" \
    "Cierra primero:
${busy_lines}"
  exit 1
fi

# Libre: desmontar + detach (apaga el bus USB del dispositivo)
if udiskie-umount --detach --all >/dev/null 2>&1; then
  notify-send -t 5000 -i "$ICON" \
    "✓ USB desmontado" "Ya puedes retirarlo de forma segura."
else
  notify-send -u critical -t 6000 -i "$ICON" \
    "✗ Error al desmontar" "Revisa con 'udiskie-umount --all' en terminal."
  exit 1
fi
