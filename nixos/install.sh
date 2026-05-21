#!/usr/bin/env bash
# ============================================================================
# Script de instalación de NixOS con la configuración de Yeshua
# ============================================================================
# Uso: ejecutar desde el live ISO de NixOS como root.
# Asume particionado BTRFS:
#   - /dev/nvme0n1p1  → EFI  (FAT32, ~512MB)
#   - /dev/nvme0n1p2  → root (BTRFS)
#
# Ajusta DISK, EFI_PART, ROOT_PART y DOTFILES_REPO antes de ejecutar.
# ============================================================================

set -euo pipefail

# ─── Configuración — EDITA ESTO ──────────────────────────────────────────────
DISK="/dev/nvme0n1"
EFI_PART="${DISK}p1"
ROOT_PART="${DISK}p2"
HOSTNAME="nixos"
USERNAME="yeshua"
DOTFILES_REPO="https://github.com/yeshua89/dotfiles"  # <-- pon tu repo real
# ─────────────────────────────────────────────────────────────────────────────

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

[[ $EUID -ne 0 ]] && die "Ejecutar como root (en el live ISO)"

# ─── 1. Particionado ──────────────────────────────────────────────────────────
partition_disk() {
  info "Particionando $DISK..."
  parted "$DISK" --script \
    mklabel gpt \
    mkpart EFI fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart ROOT btrfs 513MiB 100%
  success "Disco particionado"
}

# ─── 2. Formatear ─────────────────────────────────────────────────────────────
format_partitions() {
  info "Formateando particiones..."
  mkfs.fat -F32 -n EFI "$EFI_PART"
  mkfs.btrfs -f -L ROOT "$ROOT_PART"
  success "Particiones formateadas"
}

# ─── 3. Subvolumes BTRFS ──────────────────────────────────────────────────────
create_subvolumes() {
  info "Creando subvolumes BTRFS..."
  mount "$ROOT_PART" /mnt
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@nix
  btrfs subvolume create /mnt/@snapshots
  btrfs subvolume create /mnt/@log
  umount /mnt
  success "Subvolumes creados"
}

# ─── 4. Montar ────────────────────────────────────────────────────────────────
mount_filesystems() {
  info "Montando filesystems..."
  local OPTS="noatime,compress=zstd,space_cache=v2"

  mount -o "${OPTS},subvol=@"          "$ROOT_PART" /mnt
  mkdir -p /mnt/{boot,home,.snapshots,var/log,nix}
  mount -o "${OPTS},subvol=@home"      "$ROOT_PART" /mnt/home
  mount -o "${OPTS},subvol=@nix"       "$ROOT_PART" /mnt/nix
  mount -o "${OPTS},subvol=@snapshots" "$ROOT_PART" /mnt/.snapshots
  mount -o "${OPTS},subvol=@log"       "$ROOT_PART" /mnt/var/log
  mount "$EFI_PART" /mnt/boot
  success "Filesystems montados"
}

# ─── 5. Clonar dotfiles ───────────────────────────────────────────────────────
clone_dotfiles() {
  info "Clonando dotfiles en /mnt/home/${USERNAME}/.dotfiles ..."
  mkdir -p "/mnt/home/${USERNAME}"
  git clone "$DOTFILES_REPO" "/mnt/home/${USERNAME}/.dotfiles"
  success "Dotfiles clonados"
}

# ─── 6. Generar hardware-configuration y moverla a dotfiles ───────────────────
generate_hardware_config() {
  info "Generando hardware-configuration.nix..."
  nixos-generate-config --root /mnt

  # La movemos directo al directorio de hosts dentro de los dotfiles.
  # Así hay UNA sola fuente de verdad: ~/.dotfiles/nixos/
  cp /mnt/etc/nixos/hardware-configuration.nix \
     "/mnt/home/${USERNAME}/.dotfiles/nixos/hosts/default/hardware-configuration.nix"

  success "hardware-configuration.nix copiada a dotfiles"
}

# ─── 7. Instalar NixOS ────────────────────────────────────────────────────────
install_nixos() {
  info "Instalando NixOS (puede tardar varios minutos)..."

  # La fuente de verdad es dotfiles. NO copiamos la config a /etc/nixos.
  # nixos-install acepta rutas dentro de /mnt directamente.
  nixos-install \
    --root /mnt \
    --flake "/mnt/home/${USERNAME}/.dotfiles/nixos#default" \
    --no-root-passwd

  success "NixOS instalado"
}

# ─── 8. Post-instalación ──────────────────────────────────────────────────────
post_install() {
  info "Configurando contraseña del usuario..."
  nixos-enter --root /mnt -- passwd "${USERNAME}"

  info "Ajustando permisos de dotfiles..."
  nixos-enter --root /mnt -- chown -R "${USERNAME}:users" "/home/${USERNAME}/.dotfiles"

  # home-manager NO se ejecuta como comando separado aquí.
  # Como usamos el módulo NixOS (home-manager.nixosModules.home-manager),
  # home-manager ya se activó durante nixos-install arriba.
  # En el primer boot todo el entorno ya estará listo.

  success "Post-instalación completada"
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  echo -e "\n${BLUE}══════════════════════════════════════════${NC}"
  echo -e "${BLUE}   NixOS Install — Yeshua's config${NC}"
  echo -e "${BLUE}══════════════════════════════════════════${NC}\n"

  warn "Configuración:"
  warn "  DISK:      $DISK"
  warn "  EFI_PART:  $EFI_PART"
  warn "  ROOT_PART: $ROOT_PART"
  warn "  HOSTNAME:  $HOSTNAME"
  warn "  USERNAME:  $USERNAME"
  warn "  DOTFILES:  $DOTFILES_REPO"
  echo ""
  read -rp "¿Continuar? (s/N): " confirm
  [[ "$confirm" =~ ^[sS]$ ]] || die "Abortado"

  # Comenta las funciones de los pasos que ya hiciste manualmente
  partition_disk
  format_partitions
  create_subvolumes
  mount_filesystems
  clone_dotfiles
  generate_hardware_config
  install_nixos
  post_install

  echo -e "\n${GREEN}══════════════════════════════════════════${NC}"
  echo -e "${GREEN}   ¡Instalación completa! Reinicia.${NC}"
  echo -e "${GREEN}══════════════════════════════════════════${NC}\n"

  echo "Tras el primer boot:"
  echo ""
  echo "  Para aplicar cambios en la config del sistema:"
  echo "    sudo nixos-rebuild switch --flake ~/.dotfiles/nixos#default"
  echo ""
  echo "  Para aplicar cambios solo en home-manager (más rápido):"
  echo "    home-manager switch --flake ~/.dotfiles/nixos#default"
  echo ""
  echo "  Los dotfiles ya están enlazados — edítalos directamente en ~/.dotfiles"
}

main "$@"
