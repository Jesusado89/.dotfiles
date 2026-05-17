#!/bin/bash
# Script compacto para verificar estado de VPN

vpn_active=false
vpn_name=""

# Verificar ProtonVPN / WireGuard / OpenVPN por NetworkManager
# Filtra por columna TYPE específicamente para evitar falsos positivos por NAME.
if command -v nmcli &> /dev/null; then
    vpn_conn=$(nmcli -t -f NAME,TYPE connection show --active \
        | awk -F: '$2 == "wireguard" || $2 == "vpn" { print; exit }')
    if [ -n "$vpn_conn" ]; then
        vpn_active=true
        vpn_name=$(echo "$vpn_conn" | cut -d: -f1)
    fi
fi

# Verificar WireGuard directo
if [ "$vpn_active" = false ] && command -v wg &> /dev/null; then
    wg_interfaces=$(wg show interfaces 2>/dev/null)
    if [ -n "$wg_interfaces" ]; then
        vpn_active=true
        vpn_name="WireGuard: $wg_interfaces"
    fi
fi

# Verificar OpenVPN
if [ "$vpn_active" = false ] && pgrep -x openvpn &> /dev/null; then
    vpn_active=true
    vpn_name="OpenVPN"
fi

# Output JSON
if [ "$vpn_active" = true ]; then
    echo '{"text":"󰦝 VPN","tooltip":"VPN activa: '"$vpn_name"'","class":"connected"}'
else
    echo '{"text":"󰦞 VPN","tooltip":"VPN desconectada","class":"disconnected"}'
fi
