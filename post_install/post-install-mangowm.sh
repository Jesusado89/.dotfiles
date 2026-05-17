#!/usr/bin/env bash
# ============================================================================
# Arch Linux Post-Installation Script
# ============================================================================
# Description: Complete setup script for Arch Linux with MangoWM
# Author: Yeshua (generated with Claude Code)
# Date: $(date +%Y-%m-%d)
# ============================================================================

# NO usamos set -e para que el script continúe incluso si un paso falla
set -u # Exit on undefined variable
set -o pipefail # Exit on pipe failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Arrays para tracking de pasos
declare -a COMPLETED_STEPS=()
declare -a FAILED_STEPS=()

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should NOT be run as root (except for specific parts)"
        exit 1
    fi
}

# Wrapper para ejecutar pasos con manejo de errores
run_step() {
    local step_name="$1"
    local step_function="$2"

    echo "" # Línea en blanco para separación
    if $step_function; then
        COMPLETED_STEPS+=("$step_name")
        return 0
    else
        FAILED_STEPS+=("$step_name")
        print_error "Step '$step_name' failed, but continuing..."
        return 1
    fi
}

# ============================================================================
# STEP 1: System Update
# ============================================================================
step_system_update() {
    print_header "Updating System"
    sudo pacman -Syu --noconfirm
    print_success "System updated"
}

# ============================================================================
# STEP 2: Setup Chaotic-AUR Repository
# ============================================================================
step_setup_chaotic_aur() {
    print_header "Setting up Chaotic-AUR"

    # Check if already configured
    if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
        print_success "Chaotic-AUR already configured"
        return
    fi

    print_warning "Installing Chaotic-AUR keyring and mirrorlist..."

    # Fix keys
    if ! pacman-key --list-keys 3056513887B78AEB &>/dev/null; then
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
    fi

    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

    # Add Chaotic-AUR to pacman.conf
    if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
        sudo tee -a /etc/pacman.conf >/dev/null <<EOF

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
        print_success "Chaotic-AUR repository added to pacman.conf"
    fi

    # Update package databases
    sudo pacman -Sy

    print_success "Chaotic-AUR configured"
}

# ============================================================================
# STEP 3: Install paru (AUR helper) - via Chaotic-AUR
# ============================================================================
step_install_paru() {
    print_header "Installing paru (AUR Helper)"

    if command -v paru &>/dev/null; then
        print_success "paru already installed"
        return
    fi

    # Chaotic-AUR provee paru como binario, sin necesidad de compilar
    sudo pacman -S --needed --noconfirm paru
    print_success "paru installed"
}

# ============================================================================
# STEP 4: Install Essential Packages
# ============================================================================
step_install_essentials() {
    print_header "Installing Essential Packages"

    ESSENTIALS=(
        base base-devel linux-zen linux-zen-headers linux-firmware
        intel-ucode efibootmgr btrfs-progs
        networkmanager wpa_supplicant openssh
        zsh starship kitty
        neovim
        git wget curl unzip 7zip stow
        pacman-contrib wtype inotify-tools
    )

    sudo pacman -S --needed --noconfirm "${ESSENTIALS[@]}"
    print_success "Essential packages installed"
}

# ============================================================================
# STEP 5: Install Modern CLI Tools
# ============================================================================
step_install_modern_cli() {
    print_header "Installing Modern CLI Tools"

    MODERN_CLI=(
        bat eza fd ripgrep fzf zoxide sd
        btop bottom procs dust duf
        hyperfine
        tokei tealdeer
        git-delta lazygit github-cli glab
        yazi
        tree
    )

    sudo pacman -S --needed --noconfirm "${MODERN_CLI[@]}"
    print_success "Modern CLI tools installed"
}

# ============================================================================
# STEP 6: Install MangoWM & Wayland Ecosystem
# ============================================================================
step_install_mangowm() {
    print_header "Installing MangoWM & Wayland"

    MANGOWM_PKGS=(
        # Wayland base
        wayland wayland-protocols wlroots
        xorg-xwayland xorg-xrdb
        qt5-wayland qt6-wayland
        xdg-desktop-portal xdg-desktop-portal-wlr
        # Bar & notifications
        waybar mako
        # Launcher & clipboard
        fuzzel wlogout
        cliphist wl-clipboard
        # Wallpaper & screenshots
        swaybg grim slurp
        # Wallpaper picker (galería)
        nsxiv
        # Auto-mount USB
        udiskie
        # Idle & night light (standalone, no Hyprland needed)
        hypridle hyprsunset
        # Media & brightness
        playerctl brightnessctl
        # Bluetooth
        blueman
        # Media viewers
        mpv imv
        # Theme switcher
        nwg-look
        # PipeWire integration
        gst-plugin-pipewire
        # Lock screen
        swaylock
    )

    sudo pacman -S --needed --noconfirm "${MANGOWM_PKGS[@]}"

    # Allow brightnessctl to change backlight without sudo
    sudo usermod -aG video "$USER"

    print_warning "Installing MangoWM from AUR..."
    paru -S --needed --noconfirm mangowm-git

    print_success "MangoWM installed"
}

# ============================================================================
# STEP 7: Install Audio (PipeWire)
# ============================================================================
step_install_audio() {
    print_header "Installing Audio (PipeWire)"

    AUDIO=(
        pipewire pipewire-alsa pipewire-jack pipewire-pulse
        wireplumber libpulse sof-firmware
    )

    sudo pacman -S --needed --noconfirm "${AUDIO[@]}"

    # Intento seguro de activar servicios de usuario
    systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null ||
        systemctl --user enable pipewire pipewire-pulse wireplumber

    print_success "PipeWire audio configured"
}

# ============================================================================
# STEP 8: Install Development Tools
# ============================================================================
step_install_dev_tools() {
    print_header "Installing Development Tools"

    DEV_TOOLS=(
        cmake meson ninja
        go
        docker docker-buildx docker-compose
        vscodium
        lazydocker
    )

    sudo pacman -S --needed --noconfirm "${DEV_TOOLS[@]}"

    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER

    print_success "Development tools installed"
}

# ============================================================================
# STEP 9: Install Node.js Manager (fnm)
# ============================================================================
step_install_fnm() {
    print_header "Installing fnm (Fast Node Manager)"

    if command -v fnm &>/dev/null; then
        print_success "fnm already installed"
        return
    fi

    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    print_success "fnm installed"
}

# ============================================================================
# STEP 10: Install Python Tools
# ============================================================================
step_install_python() {
    print_header "Installing Python Tools"

    sudo pacman -S --needed --noconfirm python python-pip
    paru -S --needed --noconfirm uv

    print_success "Python tools installed"
}

# ============================================================================
# STEP 11: Install Fonts
# ============================================================================
step_install_fonts() {
    print_header "Installing Fonts"

    FONTS=(
        ttf-fira-code
        ttf-firacode-nerd
        ttf-nerd-fonts-symbols-mono
        noto-fonts-emoji
    )

    sudo pacman -S --needed --noconfirm "${FONTS[@]}"
    fc-cache -fv
    print_success "Fonts installed"
}

# ============================================================================
# STEP 12: Install Browsers
# ============================================================================
step_install_browsers() {
    print_header "Installing Browsers"

    sudo pacman -S --needed --noconfirm qutebrowser firefox

    print_warning "Installing librewolf (AUR)..."
    paru -S --needed --noconfirm librewolf-bin

    print_success "Browsers installed"
}

# ============================================================================
# STEP 13: Install Themes
# ============================================================================
step_install_themes() {
    print_header "Installing Themes"

    paru -S --needed --noconfirm mojave-ct-icon-theme newaita-reborn-icons-git phocus-gtk-theme-git

    print_success "Themes installed"
}

# ============================================================================
# STEP 14: Install Additional Tools
# ============================================================================
step_install_additional() {
    print_header "Installing Additional Tools"

    ADDITIONAL=(
        nemo
        bluez bluez-utils
        fastfetch
        power-profiles-daemon
        dmidecode
        xclip
        cpio
        scx-scheds
        python-adblock
        zram-generator
        gnome-keyring
        gnome-calendar
        wireguard-tools
        cronie
    )

    sudo pacman -S --needed --noconfirm "${ADDITIONAL[@]}"

    print_warning "Installing ProtonVPN..."
    paru -S --needed --noconfirm proton-vpn-cli

    print_warning "Installing Proton Pass CLI..."
    if ! command -v pass-cli &>/dev/null; then
        curl -fsSL https://proton.me/download/pass-cli/install.sh | bash
        print_success "Proton Pass CLI installed"
    else
        print_success "Proton Pass CLI already installed"
    fi

    sudo systemctl enable --now bluetooth

    print_success "Additional tools installed"
}

# ============================================================================
# STEP 15: Install AUR Packages (Fast Binaries)
# ============================================================================
step_install_aur() {
    print_header "Installing AUR Packages (Fast Binaries)"

    AUR_PACKAGES=(
        claude-code
        bun-bin
        localsend-bin
        yaak-bin
        swaylock-effects-git
        timeshift
        ventoy-bin
    )

    paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

    print_success "AUR packages installed"
}

# ============================================================================
# STEP 16: Setup ZSH (EJECUTAR DESPUÉS DE DOTFILES)
# ============================================================================
step_setup_zsh() {
    print_header "Setting up ZSH"

    # Install zinit if not present
    if [ ! -d "${HOME}/.local/share/zinit/zinit.git" ]; then
        print_warning "Installing zinit..."
        bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    fi

    # Change default shell to ZSH
    if [[ "$SHELL" != *"zsh"* ]]; then
        print_warning "Changing default shell to ZSH..."
        chsh -s $(which zsh)
        print_success "Shell changed to ZSH (effective after logout/login)"
    else
        print_success "ZSH is already the default shell"
    fi

    # Verificar que .zshrc existe (debería venir de dotfiles)
    if [ -f ~/.zshrc ]; then
        if [ -L ~/.zshrc ]; then
            print_success "ZSH config linked from dotfiles"
        else
            print_warning "ZSH config exists but is not a symlink (may not be from dotfiles)"
        fi
    else
        print_warning "No .zshrc found - dotfiles may not have been applied correctly"
    fi

    print_success "ZSH setup complete"
}

# ============================================================================
# STEP 17: Setup Git
# ============================================================================
step_setup_git() {
    print_header "Setting up Git"

    if git config --global user.name &>/dev/null; then
        print_success "Git already configured"
        return
    fi

    read -p "Enter your Git name: " git_name
    read -p "Enter your Git email: " git_email

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"

    print_success "Git configured"
}

# ============================================================================
# STEP 18: Restore Dotfiles with Stow
# ============================================================================
step_restore_dotfiles() {
    print_header "Restoring Dotfiles"

    DOTFILES_REPO="https://github.com/yeshua89/.dotfiles"
    DOTFILES_DIR="$HOME/.dotfiles"
    CONFIGS_TO_APPLY=(zsh nvim waybar-mango mango mako nsxiv xresources fuzzel starship qutebrowser kitty)

    if [ ! -d "$DOTFILES_DIR" ]; then
        print_warning "Cloning dotfiles..."
        if ! git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
            print_error "Failed to clone dotfiles repository"
            return 1
        fi
    else
        print_warning "Pulling latest changes..."
        cd "$DOTFILES_DIR" && git pull origin main 2>/dev/null || true
    fi

    if [ -d "$DOTFILES_DIR" ]; then
        print_warning "Applying dotfiles with stow..."
        cd "$DOTFILES_DIR"

        # Backup .zshrc if exists and is not a symlink (antes de aplicar dotfiles)
        if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
            print_warning "Backing up existing .zshrc to .zshrc.pre-dotfiles"
            mv "$HOME/.zshrc" "$HOME/.zshrc.pre-dotfiles"
        fi

        for config in "${CONFIGS_TO_APPLY[@]}"; do
            if [ -d "$config" ]; then
                # Backup if exists and is not a symlink
                if [ -d "$HOME/.config/$config" ] && [ ! -L "$HOME/.config/$config" ]; then
                    print_warning "Backing up existing $config to $config.pre-dotfiles"
                    mv "$HOME/.config/$config" "$HOME/.config/${config}.pre-dotfiles"
                fi

                # Apply dotfiles with stow (-R forces restow if already exists)
                if stow -R "$config" 2>/dev/null; then
                    print_success "Applied $config dotfiles"
                else
                    print_warning "Failed to apply $config dotfiles (may already be linked)"
                fi
            fi
        done
        # Link waybar scripts from base waybar dotfiles (waybar-mango doesn't include them)
        if [ -d "$DOTFILES_DIR/waybar/.config/waybar/scripts" ]; then
            ln -sf "$DOTFILES_DIR/waybar/.config/waybar/scripts" "$HOME/.config/waybar/scripts"
            print_success "Linked waybar scripts"
        fi

        cd "$HOME"
        print_success "Dotfiles configuration complete"
    fi

    # Create required directories
    mkdir -p "$HOME/Screenshots"
    print_success "Created ~/Screenshots directory"
}

# ============================================================================
# STEP 19: Setup Services
# ============================================================================
step_setup_services() {
    print_header "Enabling Services"

    sudo systemctl enable --now NetworkManager
    sudo systemctl enable --now power-profiles-daemon
    sudo systemctl enable --now cronie

    if [ -f /etc/systemd/zram-generator.conf ]; then
        sudo systemctl daemon-reload
        sudo systemctl start systemd-zram-setup@zram0.service
    fi

    print_success "Services enabled"
}

# ============================================================================
# STEP 20: Performance Optimizations
# ============================================================================
step_performance_optimization() {
    print_header "Applying Performance Optimizations"

    if [ ! -f /etc/systemd/zram-generator.conf ]; then
        sudo tee /etc/systemd/zram-generator.conf >/dev/null <<EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF
    fi

    if ! grep -q "^ParallelDownloads" /etc/pacman.conf; then
        sudo sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
    fi

    print_success "Performance optimizations applied"
}

# ============================================================================
# STEP 21: Setup Claude Code
# ============================================================================
step_setup_claude_code() {
    print_header "Setting up Claude Code Configuration"

    if [[ ! -d "$HOME/.dotfiles/claude" ]]; then
        print_warning "Claude config not found, skipping..."
        return
    fi

    # Config Link
    mkdir -p "$HOME/.config"
    if [[ ! -L "$HOME/.config/claude" ]]; then
        ln -sf "$HOME/.dotfiles/claude" "$HOME/.config/claude"
    fi

    # Scripts Links
    mkdir -p "$HOME/.local/bin"
    for script in searxng-search claude-backup claude-check; do
        if [[ -f "$HOME/.dotfiles/scripts/$script" ]]; then
            ln -sf "$HOME/.dotfiles/scripts/$script" "$HOME/.local/bin/$script"
            chmod +x "$HOME/.dotfiles/scripts/$script"
        fi
    done

    # SearXNG Link
    if [[ -d "$HOME/.dotfiles/searxng" ]] && [[ ! -L "$HOME/searxng" ]]; then
        if [[ -d "$HOME/searxng" ]]; then mv "$HOME/searxng" "$HOME/searxng.bak"; fi
        ln -sf "$HOME/.dotfiles/searxng" "$HOME/searxng"
    fi

    print_success "Claude Code setup complete"
}

# ============================================================================
# STEP 22: Cleanup
# ============================================================================
step_cleanup() {
    print_header "Cleaning up"
    if command -v paru &>/dev/null; then
        paru -Sc --noconfirm || print_warning "paru cleanup had issues, continuing..."
    fi
    sudo rm -f /var/cache/pacman/pkg/download-* 2>/dev/null
    sudo pacman -Sc --noconfirm || print_warning "pacman cleanup had issues, continuing..."
    print_success "Cleanup complete"
    return 0 # Always succeed, cleanup is not critical
}

# ============================================================================
# STEP 23: Summary
# ============================================================================
step_summary() {
    print_header "Installation Complete!"

    # Mostrar pasos completados
    if [ ${#COMPLETED_STEPS[@]} -gt 0 ]; then
        echo -e "${GREEN}✓ Pasos completados exitosamente (${#COMPLETED_STEPS[@]}):${NC}"
        for step in "${COMPLETED_STEPS[@]}"; do
            echo -e "  ${GREEN}✓${NC} $step"
        done
        echo ""
    fi

    # Mostrar pasos fallidos si los hay
    if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
        echo -e "${RED}✗ Pasos que fallaron (${#FAILED_STEPS[@]}):${NC}"
        for step in "${FAILED_STEPS[@]}"; do
            echo -e "  ${RED}✗${NC} $step"
        done
        echo ""
        echo -e "${YELLOW}⚠ Algunos pasos fallaron. Revisa los errores arriba.${NC}\n"
    else
        echo -e "${GREEN}✓ Todos los pasos se completaron exitosamente${NC}\n"
    fi

    echo -e "${YELLOW}Please REBOOT your system now.${NC}\n"
    echo -e "${BLUE}Después del reinicio puedes iniciar MangoWM:${NC}"
    echo -e "  ${YELLOW}•${NC} Desde TTY: ${BLUE}dbus-run-session mango${NC}"
    echo -e "  ${YELLOW}•${NC} Con SDDM (recomendado): instala ${BLUE}sddm${NC} y ejecuta ${BLUE}sudo systemctl enable --now sddm${NC}"
    echo -e "    (MangoWM aparece como 'Mango' en la lista de sesiones)"
    echo -e "  ${YELLOW}⚠${NC} Recuerda poblar ${BLUE}~/Backgrounds/${NC} con tus wallpapers (el theme-switcher referencia 12.png como default inicial)"
    echo ""
}

# ============================================================================
# Main Script Execution
# ============================================================================
main() {
    check_root

    print_header "Arch Linux Post-Installation Script (MangoWM)"
    echo "Press Enter to continue..."
    read

    # ========================================================================
    # ORDEN DE EJECUCIÓN - IMPORTANTE: NO MODIFICAR SIN ENTENDER DEPENDENCIAS
    # ========================================================================
    # El orden de los pasos es CRÍTICO para evitar conflictos de archivos:
    #
    # 1. Instalación de paquetes primero (incluyendo stow, git, zsh)
    # 2. Configurar Git ANTES de clonar dotfiles (necesita git config)
    # 3. Restaurar Dotfiles ANTES de setup ZSH (evita que stow falle)
    #    - Si se hace setup ZSH primero, se crea ~/.zshrc
    #    - Luego stow FALLA porque ~/.zshrc ya existe y no es symlink
    # 4. Setup ZSH DESPUÉS de dotfiles (solo cambia shell, no crea configs)
    # 5. Setup Claude Code al final (usa configs de dotfiles)
    # ========================================================================

    run_step "System Update" step_system_update
    run_step "Setup Chaotic-AUR" step_setup_chaotic_aur
    run_step "Install Essential Packages" step_install_essentials
    run_step "Install paru (AUR Helper)" step_install_paru
    run_step "Install Modern CLI Tools" step_install_modern_cli
    run_step "Install MangoWM & Wayland" step_install_mangowm
    run_step "Install Audio (PipeWire)" step_install_audio
    run_step "Install Development Tools" step_install_dev_tools
    run_step "Install fnm (Node Manager)" step_install_fnm
    run_step "Install Python Tools" step_install_python
    run_step "Install Fonts" step_install_fonts
    run_step "Install Browsers" step_install_browsers
    run_step "Install Themes" step_install_themes
    run_step "Install Additional Tools" step_install_additional
    run_step "Install AUR Packages" step_install_aur
    run_step "Setup Git" step_setup_git
    run_step "Restore Dotfiles" step_restore_dotfiles
    run_step "Setup ZSH" step_setup_zsh
    run_step "Setup Services" step_setup_services
    run_step "Performance Optimizations" step_performance_optimization
    run_step "Setup Claude Code" step_setup_claude_code
    run_step "Cleanup" step_cleanup

    step_summary
}

# Run main function
main "$@"
