-- ============================================================================
-- Hyprland Lua config (migrated from hyprland.conf for Hyprland 0.55+)
-- Docs: https://wiki.hypr.land/Configuring/Start/
-- ============================================================================

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = 1,
})


--------------------
---- PROGRAMS  ----
--------------------

local terminal    = "kitty"
local fileManager = "nemo"
local menu        = "fuzzel"


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
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE",                    "24")
hl.env("HYPRCURSOR_SIZE",                 "24")
hl.env("XDG_SESSION_TYPE",                "wayland")
hl.env("XDG_CURRENT_DESKTOP",             "Hyprland")
hl.env("MOZ_ENABLE_WAYLAND",              "1")
hl.env("QT_QPA_PLATFORM",                 "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND",                     "wayland,x11")
hl.env("SDL_VIDEODRIVER",                 "wayland")
hl.env("CLUTTER_BACKEND",                 "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT",    "wayland")
hl.env("_JAVA_AWT_WM_NONREPARENTING",     "1")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 8,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(82FB9CDD)", "rgba(86A7DFAA)" }, angle = 45 },
            inactive_border = "rgba(23242DAA)",
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 10,
        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        dim_inactive = true,
        dim_strength = 0.08,

        shadow = {
            enabled        = true,
            range          = 10,
            render_power   = 2,
            color          = "rgba(00000059)",
            color_inactive = "rgba(00000026)",
        },

        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
        force_split    = 2,
        -- Note: dwindle.pseudotile was removed in Hyprland 0.55
    },

    master = {
        new_status = "master",
    },

    -- Native scrolling layout (0.55) — replaces the old hyprscrolling plugin
    scrolling = {
        column_width             = 0.7,
        fullscreen_on_one_column = true,
        focus_fit_method         = 1,
        follow_focus             = true,
    },

    misc = {
        force_default_wallpaper        = 0,
        disable_hyprland_logo          = true,
        disable_splash_rendering       = true,
        vrr                            = 0,
        mouse_move_enables_dpms        = true,
        key_press_enables_dpms         = true,
        animate_manual_resizes         = false,
        animate_mouse_windowdragging   = false,
        enable_swallow                 = true,
        swallow_regex                  = "^(kitty)$",
        focus_on_activate              = true,
        -- Note: misc.vfr moved to debug.vfr in 0.55 (debug option; default is fine)
    },

    cursor = {
        no_hardware_cursors = false,
        enable_hyprcursor   = true,
        hide_on_key_press   = false,
    },

    input = {
        kb_layout       = "us",
        follow_mouse    = 1,
        sensitivity     = 0,
        accel_profile   = "adaptive",
        force_no_accel  = false,

        touchpad = {
            natural_scroll       = true,
            scroll_factor        = 0.5,
            disable_while_typing = true,
            tap_to_click         = true,
            drag_lock            = 0,
            clickfinger_behavior = true,
        },
    },
})


--------------------
---- ANIMATIONS ----
--------------------

hl.curve("smooth",   { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 }    } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1,  1.05 } } })
hl.curve("snappy",   { type = "bezier", points = { { 0.4,  0   }, { 0.2,  1    } } })

hl.animation({ leaf = "windows",          enabled = true,  speed = 3,  bezier = "smooth",   style = "slide" })
hl.animation({ leaf = "windowsIn",        enabled = true,  speed = 3,  bezier = "overshot", style = "popin 95%" })
hl.animation({ leaf = "windowsOut",       enabled = true,  speed = 2,  bezier = "snappy",   style = "popin 90%" })
hl.animation({ leaf = "windowsMove",      enabled = true,  speed = 3,  bezier = "smooth",   style = "slide" })
hl.animation({ leaf = "border",           enabled = false, speed = 8,  bezier = "smooth" })
hl.animation({ leaf = "borderangle",      enabled = false, speed = 50, bezier = "smooth",   style = "loop" })
hl.animation({ leaf = "fade",             enabled = true,  speed = 4,  bezier = "smooth" })
hl.animation({ leaf = "workspaces",       enabled = true,  speed = 3,  bezier = "overshot", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true,  speed = 3,  bezier = "overshot", style = "slidevert" })


-------------------
---- GESTURES  ----
-------------------

-- 3-finger horizontal swipe to change workspace (new gesture API in 0.55)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })


----------------------
---- WINDOW RULES ----
----------------------

-- Opacity
hl.window_rule({ match = { class = "kitty" }, opacity = "0.92 0.88" })
hl.window_rule({ match = { class = "nemo"  }, opacity = "0.95 0.90" })

-- Floating by class
hl.window_rule({
    match = { class = "^(pavucontrol|nm-applet|nm-connection-editor|org.gnome.Calculator|imv|mpv|vlc|eog)$" },
    float = true,
})

-- Floating by title (file dialogs)
hl.window_rule({
    match = { title = "^(Open File|Save File|Save As)$" },
    float = true,
})

-- Center floating windows
hl.window_rule({ match = { float = true }, center = true })

-- Picture-in-Picture
hl.window_rule({
    match = { title = "Picture-in-Picture" },
    float = true,
    pin   = true,
    size  = { "monitor_w * 0.25", "monitor_h * 0.25" },
})

-- Utility window sizes
hl.window_rule({
    match = { class = "pavucontrol" },
    size  = { "monitor_w * 0.40", "monitor_h * 0.50" },
})
hl.window_rule({
    match = { class = "org.gnome.Calculator" },
    size  = { "monitor_w * 0.30", "monitor_h * 0.40" },
})

-- Dropdown terminal (triggered by F12)
hl.window_rule({
    match  = { class = "dropdown" },
    float  = true,
    size   = { 1050, 430 },
    center = true,
})


---------------------
---- LAYER RULES ----
---------------------

hl.layer_rule({
    match        = { namespace = "waybar" },
    blur         = true,
    ignore_alpha = 0.05,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Dropdown terminal
hl.bind("F12", hl.dsp.exec_cmd("~/.config/hypr/scripts/dropdown.sh"))

-- Apps
hl.bind(mainMod .. " + Return",     hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",          hl.dsp.window.close())
hl.bind(mainMod .. " + E",          hl.dsp.exec_cmd("qutebrowser"))
hl.bind(mainMod .. " + SHIFT + L",  hl.dsp.exec_cmd("swaylock"))
hl.bind(mainMod .. " + SHIFT + Q",  hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + R",  hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + W",          hl.dsp.exec_cmd("~/.config/waybar/scripts/launch.sh"))
hl.bind(mainMod .. " + V",          hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",          hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",          hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",          hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + M",          hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + C",          hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + N",          hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + Tab",        hl.dsp.focus({ workspace = "previous" }))

-- Toggle layout between dwindle and scrolling (clean Lua version)
hl.bind(mainMod .. " + ALT + L", function()
    local current = hl.get_config("general.layout")
    if current == "scrolling" then
        hl.config({ general = { layout = "dwindle" } })
    else
        hl.config({ general = { layout = "scrolling" } })
    end
end)

-- ============================================================================
-- SCROLLING LAYOUT (native, 0.55)
-- ============================================================================

-- Move the layout horizontally between columns
hl.bind(mainMod .. " + ALT + left",  hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + ALT + right", hl.dsp.layout("move +col"))

-- Swap current column with neighbor (was hyprscrolling's "movewindowto l/r")
hl.bind(mainMod .. " + ALT + SHIFT + left",  hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + ALT + SHIFT + right", hl.dsp.layout("swapcol r"))

-- Resize current column
hl.bind(mainMod .. " + ALT + CTRL + left",  hl.dsp.layout("colresize -0.1"))
hl.bind(mainMod .. " + ALT + CTRL + right", hl.dsp.layout("colresize +0.1"))

-- Cycle through preconfigured column widths (your existing script)
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-column-size.sh"))

-- New 0.55 scrolling dispatchers
hl.bind(mainMod .. " + ALT + e", hl.dsp.layout("expel"))                  -- move window to its own column
hl.bind(mainMod .. " + ALT + i", hl.dsp.layout("consume_or_expel prev"))  -- consume into prev column or expel
hl.bind(mainMod .. " + ALT + p", hl.dsp.layout("promote"))                -- promote window to a new column
hl.bind(mainMod .. " + ALT + f", hl.dsp.layout("fit active"))             -- fit active column on screen

-- ============================================================================
-- WINDOW RESIZE (SUPER + CTRL + arrows / hjkl)
-- ============================================================================

hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

-- Mouse drag/resize (SUPER + LMB = drag, SUPER + RMB = resize)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ============================================================================
-- FOCUS / MOVE
-- ============================================================================

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left"  }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up"    }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down"  }))

-- ============================================================================
-- WORKSPACES
-- ============================================================================

for i = 1, 7 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Special workspaces
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scratchpad terminal (SUPER + ~)
hl.bind(mainMod .. " + grave",         hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Mouse wheel cycles workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ============================================================================
-- SCREENSHOTS
-- ============================================================================

hl.bind("Print",         hl.dsp.exec_cmd("hyprshot -m window -o ~/Screenshots/"))
hl.bind("CTRL + Print",  hl.dsp.exec_cmd("hyprshot -m output -o ~/Screenshots/"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))

-- ============================================================================
-- MULTIMEDIA
-- ============================================================================

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                         { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                         { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
