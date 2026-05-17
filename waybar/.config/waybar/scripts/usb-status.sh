#!/usr/bin/env bash
# Reporta el estado de pendrives/USB removibles para waybar.
# Detecta discos con tran=usb o rm=true.

set -euo pipefail

lsblk_json=$(lsblk -J -o NAME,SIZE,LABEL,MOUNTPOINT,RM,HOTPLUG,TYPE,TRAN 2>/dev/null || echo '{"blockdevices":[]}')

# Filtra discos removibles/USB y aplana sus particiones a una lista plana.
parts_json=$(echo "$lsblk_json" | jq -c '
  [ .blockdevices[]
    | select(.tran == "usb" or .rm == true)
    | . as $disk
    | ( $disk.children // [ $disk ] )[]
    | select(.type == "part" or .type == "disk")
    | { disk: $disk.name, disk_size: $disk.size,
        name: .name, size: .size,
        label: (.label // ""),
        mount: (.mountpoint // "") }
  ]
')

count=$(echo "$parts_json" | jq 'length')

if [[ "$count" -eq 0 ]]; then
  printf '{"text":"","tooltip":"","class":"empty","alt":"empty"}\n'
  exit 0
fi

mounted=$(echo "$parts_json" | jq '[ .[] | select(.mount != "") ] | length')

# Etiqueta corta: primer label no vacío, o el nombre del primer disco
first_label=$(echo "$parts_json" | jq -r 'first(.[] | select(.label != "") | .label) // ""')
if [[ -z "$first_label" ]]; then
  first_label=$(echo "$parts_json" | jq -r '.[0].disk')
fi
# Truncar a 12 caracteres
if [[ ${#first_label} -gt 12 ]]; then
  first_label="${first_label:0:12}…"
fi

if [[ "$count" -gt 1 ]]; then
  text="󰕓 ${first_label} +$((count-1))"
else
  text="󰕓 ${first_label}"
fi

# Tooltip con líneas por partición; usa \n literal que Pango interpreta.
tooltip=$(echo "$parts_json" | jq -r '
  group_by(.disk) | .[] |
  "<b>\(.[0].disk)</b> (\(.[0].disk_size))",
  ( .[] | "  /dev/\(.name) · \(if .label == "" then "(sin etiqueta)" else .label end) · \(.size) → \(if .mount == "" then "sin montar" else .mount end)" )
' | sed ':a;N;$!ba;s/\n/\\n/g')

if [[ "$mounted" -gt 0 ]]; then
  class="mounted"
else
  class="unmounted"
fi

# Construye JSON final con jq para escapar correctamente
jq -nc --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
  '{text: $text, tooltip: $tooltip, class: $class, alt: $class}'
