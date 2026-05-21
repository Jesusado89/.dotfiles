{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix  # generado por nixos-generate-config
  ];

  # ─── Boot ───────────────────────────────────────────────────────────────────
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "btrfs" ];
    initrd.kernelModules = [ "btrfs" ];

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };
  };

  # ─── Hostname & Locale ──────────────────────────────────────────────────────
  networking = {
    hostName = "nixos";   # cambia esto
    networkmanager.enable = true;
  };

  time.timeZone = "America/Bogota";   # ajusta tu timezone
  i18n.defaultLocale = "es_CO.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "es_CO.UTF-8";
    LC_IDENTIFICATION = "es_CO.UTF-8";
    LC_MEASUREMENT    = "es_CO.UTF-8";
    LC_MONETARY       = "es_CO.UTF-8";
    LC_NAME           = "es_CO.UTF-8";
    LC_NUMERIC        = "es_CO.UTF-8";
    LC_PAPER          = "es_CO.UTF-8";
    LC_TELEPHONE      = "es_CO.UTF-8";
    LC_TIME           = "es_CO.UTF-8";
  };

  # ─── Nix Settings ───────────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkN8LA+Y1+ntp8S2+odkU="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # ─── Hardware ───────────────────────────────────────────────────────────────
  hardware = {
    cpu.intel.updateMicrocode = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # ─── Audio (PipeWire) ───────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # ─── Display / Wayland ──────────────────────────────────────────────────────
  programs.mango = {
    enable = true;
    xwayland.enable = true;
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  # tuigreet muestra menú de sesiones al login (MangoWM o Hyprland)
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --sessions /etc/greetd/sessions";
      user = "greeter";
    };
  };

  # XDG portals — nivel sistema, no duplicar en home-manager
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # ─── Services ───────────────────────────────────────────────────────────────
  services = {
    openssh.enable = true;
    power-profiles-daemon.enable = true;
    blueman.enable = true;
    btrfs.autoScrub.enable = true;

    snapper = {
      snapshotInterval = "hourly";
      cleanupInterval  = "1d";
      configs.root = {
        subvolume = "/";
        extraConfig = ''
          ALLOW_USERS="yeshua"
          TIMELINE_CREATE=yes
          TIMELINE_CLEANUP=yes
          TIMELINE_LIMIT_HOURLY=6
          TIMELINE_LIMIT_DAILY=7
          TIMELINE_LIMIT_WEEKLY=4
          TIMELINE_LIMIT_MONTHLY=1
        '';
      };
    };

    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    '';
  };

  # ─── Docker ─────────────────────────────────────────────────────────────────
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  # ─── Security ───────────────────────────────────────────────────────────────
  security = {
    sudo.wheelNeedsPassword = true;
    polkit.enable = true;
    pam.services.swaylock = {};   # necesario para que swaylock pueda autenticar
  };

  # Gnome Keyring (corrección: va en services, no en security)
  services.gnome.gnome-keyring.enable = true;

  # ─── Fuentes del sistema ────────────────────────────────────────────────────
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      fira-code
      # nixpkgs unstable: paquetes individuales en vez de nerdfonts.override
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
    ];
    fontconfig.defaultFonts = {
      serif     = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "FiraCode Nerd Font Mono" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };

  # ─── Programas del sistema ──────────────────────────────────────────────────
  programs = {
    zsh.enable    = true;   # shell por defecto del sistema
    git.enable    = true;
    dconf.enable  = true;   # necesario para GTK settings
    gnupg.agent = {
      enable           = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs; [
    wget curl git unzip p7zip stow tree cmake
    xorg.xrdb wl-clipboard xclip wtype
    sof-firmware linux-firmware
  ];

  # ─── Usuario ─────────────────────────────────────────────────────────────────
  users.users.yeshua = {
    isNormalUser = true;
    description  = "Yeshua";
    extraGroups  = [ "wheel" "networkmanager" "docker" "video" "audio" "input" ];
    shell        = pkgs.zsh;
  };

  system.stateVersion = "25.05";
}
