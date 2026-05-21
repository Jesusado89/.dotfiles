# Overlays y paquetes sin equivalente en nixpkgs

Estos paquetes de tu Arch/AUR no tienen equivalente directo en nixpkgs.
Opciones para cada uno:

## mangowm-git → YA RESUELTO
MangoWM tiene su propio flake con módulo NixOS oficial.
Ya está configurado en `flake.nix` como input y habilitado con `programs.mango.enable = true`.
No necesita overlay ni estar en nixpkgs.

## phocus-gtk-theme / newaita-reborn-icons / mojave-ct-icon-theme
Temas GTK no empaquetados en nixpkgs. Opciones:
1. Descargarlos manualmente a `~/.local/share/themes/` o `~/.local/share/icons/`
2. Empaquetarlos con un derivation propio
3. Sustituirlos por temas disponibles (Papirus, Catppuccin, etc.)

## swaylock-effects
nixpkgs tiene `swaylock` estándar. Si necesitas los efectos:
```nix
# En flake.nix, agrega el input:
swaylock-effects.url = "github:mortie/swaylock-effects";
# En home.nix:
home.packages = [ inputs.swaylock-effects.packages.${pkgs.system}.default ];
```

## scenefx
```nix
scenefx.url = "github:wlrfx/scenefx";
```

## yaak
No está en nixpkgs. Alternativas: Bruno (`pkgs.bruno`), Insomnia, o usar AppImage.

## claude-code
Instalar vía npm después del primer boot:
```bash
npm install -g @anthropic-ai/claude-code
```
O agregar a home.nix:
```nix
home.packages = [ (pkgs.nodePackages.callPackage ./pkgs/claude-code.nix {}) ];
```

## scx-scheds (Linux schedulers)
Disponible en nixpkgs unstable como `scx`:
```nix
boot.kernelModules = [ "sched_ext" ];
services.scx.enable = true;
```

## paru
No necesario en NixOS. Usa `nix search nixpkgs <paquete>` y `nix-env` o agrega a flake.

## Ejemplo de overlay personalizado
```nix
# En flake.nix, dentro de nixosSystem:
nixpkgs.overlays = [
  (final: prev: {
    mi-paquete = final.stdenv.mkDerivation {
      name = "mi-paquete";
      src = fetchFromGitHub { ... };
      buildInputs = [ ... ];
      installPhase = "...";
    };
  })
];
```
