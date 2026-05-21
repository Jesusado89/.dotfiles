{ config, pkgs, inputs, ... }:

# mkOutOfStoreSymlink crea un symlink real al path, sin copiar al Nix store.
# Así tus edits en ~/.dotfiles se reflejan sin necesidad de rebuild.
let
  dotfiles = "/home/yeshua/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home = {
    username      = "yeshua";
    homeDirectory = "/home/yeshua";
    stateVersion  = "25.05";

    sessionVariables = {
      EDITOR   = "nvim";
      VISUAL   = "nvim";
      TERMINAL = "kitty";
      BROWSER  = "qutebrowser";
      XDG_CURRENT_DESKTOP = "mango";
      XDG_SESSION_TYPE    = "wayland";
      XDG_SESSION_DESKTOP = "mango";
      MOZ_ENABLE_WAYLAND  = "1";
      QT_QPA_PLATFORM     = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      NIXOS_OZONE_WL = "1";   # Electron apps en Wayland
    };

    # ─── Paquetes de usuario ─────────────────────────────────────────────────
    packages = with pkgs; [
      # ── Terminales / Shell ────────────────────────────────────────────────
      kitty
      starship
      zoxide
      fzf

      # ── Editor ───────────────────────────────────────────────────────────
      neovim

      # ── CLI modernas ──────────────────────────────────────────────────────
      bat eza fd ripgrep sd dust duf procs bottom btop
      hyperfine tokei tealdeer fastfetch tree

      # ── Git ───────────────────────────────────────────────────────────────
      git
      delta        # git-delta: pager para diffs (en nixpkgs el paquete es "delta")
      lazygit
      gh           # github-cli
      glab         # gitlab-cli

      # ── Wayland / WM ─────────────────────────────────────────────────────
      waybar
      mako
      fuzzel
      swaylock-effects   # swaylock con blur/efectos
      swaybg
      wlogout
      hypridle
      hyprsunset
      cliphist
      wl-clipboard
      wtype
      udiskie

      # ── File Managers ─────────────────────────────────────────────────────
      yazi
      ranger
      nemo

      # ── Multimedia ────────────────────────────────────────────────────────
      mpv
      imv
      nsxiv

      # ── Browsers ─────────────────────────────────────────────────────────
      qutebrowser
      firefox
      librewolf

      # ── Dev tools ─────────────────────────────────────────────────────────
      go
      fnm
      bun
      uv
      python3
      vscodium
      lazydocker
      inotify-tools

      # ── Network ───────────────────────────────────────────────────────────
      protonvpn-cli
      wireguard-tools
      wget

      # ── Misc ──────────────────────────────────────────────────────────────
      brightnessctl
      nwg-look
      localsend
      ventoy
      snapper
      p7zip
      unzip
      cmake
      stow
    ];

    # ─── Dotfiles via symlinks reales (mkOutOfStoreSymlink) ──────────────────
    # Los cambios en ~/.dotfiles se aplican inmediatamente sin rebuild.
    file = {
      ".zshrc".source                      = link "zsh/.zshrc";
      ".config/kitty".source               = link "kitty/.config/kitty";
      ".config/nvim".source                = link "nvim/.config/nvim";
      ".config/waybar".source              = link "waybar-mango/.config/waybar";
      ".config/fuzzel".source              = link "fuzzel/.config/fuzzel";
      ".config/mako".source                = link "mako/.config/mako";
      ".config/swaylock".source            = link "swaylock/.config/swaylock";
      ".config/qutebrowser".source         = link "qutebrowser/.config/qutebrowser";
      ".config/yazi".source                = link "yazi/.config/yazi";
      ".config/starship.toml".source       = link "starship/.config/starship.toml";
      ".Xresources".source                 = link "xresources/.Xresources";
      ".config/hypr".source                = link "hypr/.config/hypr";
      ".config/mango".source               = link "mango/.config/mango";
    };
  };

  # ─── Git ──────────────────────────────────────────────────────────────────────
  programs.git = {
    enable    = true;
    userName  = "yeshua89";
    userEmail = "jesusdatica.dev@gmail.com";
    delta.enable = true;
    extraConfig = {
      init.defaultBranch     = "main";
      interactive.diffFilter = "delta --color-only";
      core.pager             = "delta";
    };
  };

  # ─── Zsh ──────────────────────────────────────────────────────────────────────
  # Solo habilitamos zsh en home-manager para que genere las completions, etc.
  # El .zshrc real viene del symlink arriba (dotfiles/zsh/.zshrc con zinit).
  # Sin dotDir: zsh busca ~/.zshrc en el home root, que es donde apunta el link.
  programs.zsh.enable = true;

  # ─── Starship ─────────────────────────────────────────────────────────────────
  # NO habilitamos programs.starship porque generaría su propio starship.toml
  # y entraría en conflicto con el symlink de home.file arriba.
  # El binario viene de home.packages y la config del symlink.

  # ─── GTK ──────────────────────────────────────────────────────────────────────
  gtk = {
    enable = true;
    theme = {
      name    = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      size = 24;
    };
  };

  # ─── XDG ──────────────────────────────────────────────────────────────────────
  # Los portales XDG van en configuration.nix (nivel sistema), no aquí.
  xdg = {
    enable = true;
    userDirs = {
      enable            = true;
      createDirectories = true;
      desktop           = "${config.home.homeDirectory}/Desktop";
      download          = "${config.home.homeDirectory}/Downloads";
      pictures          = "${config.home.homeDirectory}/Pictures";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html"             = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https"= "librewolf.desktop";
        "image/png"             = "imv.desktop";
        "image/jpeg"            = "imv.desktop";
        "video/mp4"             = "mpv.desktop";
        "video/mkv"             = "mpv.desktop";
        "inode/directory"       = "nemo.desktop";
      };
    };
  };

  # ─── Servicios de usuario ─────────────────────────────────────────────────────
  services = {
    ssh-agent.enable = true;

    udiskie = {
      enable    = true;
      automount = true;
      notify    = true;
    };

    # cliphist: el daemon lo lanza MangoWM vía exec-once en tu config.conf
    # No hay módulo services.cliphist en home-manager; el paquete está en home.packages.
  };

  programs.home-manager.enable = true;
}
