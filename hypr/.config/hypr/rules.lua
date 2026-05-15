-- ============================================================================
-- Rules — window, layer, and workspace rules.
-- ============================================================================


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

-- Picture-in-Picture (static rule; behaviors.lua handles late title changes)
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

-- Dropdown terminal (F12)
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


-------------------------
---- SMART GAPS / RULES ----
-------------------------

-- "No gaps when only one tiled window is visible", and on fullscreened workspaces.
-- w[tv1] = 1 tiled+visible window. f[1] = fullscreen workspace.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })

hl.window_rule({
    name        = "no-gaps-when-only-w",
    match       = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name        = "no-gaps-when-only-f",
    match       = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})
