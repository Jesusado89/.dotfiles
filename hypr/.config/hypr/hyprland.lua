-- ============================================================================
-- Hyprland — entry point
-- Each require() runs in its own Lua scope; an error in one module
-- will not break the others.
-- Docs: https://wiki.hypr.land/Configuring/Start/
-- ============================================================================

-- Let require() find modules in ~/.config/hypr/
package.path = os.getenv("HOME") .. "/.config/hypr/?.lua;" .. package.path


------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = 1,
})

-- Fallback for any other monitor that gets plugged in.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE",                        "24")
hl.env("HYPRCURSOR_SIZE",                     "24")
hl.env("XDG_SESSION_TYPE",                    "wayland")
hl.env("XDG_CURRENT_DESKTOP",                 "Hyprland")
hl.env("MOZ_ENABLE_WAYLAND",                  "1")
hl.env("QT_QPA_PLATFORM",                     "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND",                         "wayland,x11")
hl.env("SDL_VIDEODRIVER",                     "wayland")
hl.env("CLUTTER_BACKEND",                     "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT",        "wayland")
hl.env("_JAVA_AWT_WM_NONREPARENTING",         "1")


------------------
---- GESTURES ----
------------------

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("/usr/lib/hyprpolkitagent")
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)


-----------------
---- MODULES ----
-----------------

require("theme")     -- general / decoration / animations / dwindle / master / scrolling / misc / cursor / input
require("rules")     -- window + layer + workspace rules
require("keybinds")  -- keybinds + resize submap + reactive behaviors
