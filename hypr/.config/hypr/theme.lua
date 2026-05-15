-- ============================================================================
-- Theme — visual configuration.
-- General, decoration, dwindle/master/scrolling, misc, cursor, input,
-- bezier curves, and animations.
-- ============================================================================

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
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        column_width             = 0.7,
        fullscreen_on_one_column = true,
        focus_fit_method         = 1,
        follow_focus             = true,
        wrap_focus               = true,
    },

    misc = {
        force_default_wallpaper      = 0,
        disable_hyprland_logo        = true,
        disable_splash_rendering     = true,
        vrr                          = 0,
        mouse_move_enables_dpms      = true,
        key_press_enables_dpms       = true,
        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,
        enable_swallow               = true,
        swallow_regex                = "^(kitty)$",
        focus_on_activate            = true,
    },

    cursor = {
        no_hardware_cursors = false,
        enable_hyprcursor   = true,
        hide_on_key_press   = false,
    },

    input = {
        kb_layout      = "us",
        follow_mouse   = 1,
        sensitivity    = 0,
        accel_profile  = "adaptive",
        force_no_accel = false,

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


-------------------
---- CURVES    ----
-------------------

hl.curve("smooth",   { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 }    } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1,  1.05 } } })
hl.curve("snappy",   { type = "bezier", points = { { 0.4,  0   }, { 0.2,  1    } } })


-------------------
---- ANIMATIONS ----
-------------------

hl.animation({ leaf = "windows",          enabled = true,  speed = 3,  bezier = "smooth",   style = "slide" })
hl.animation({ leaf = "windowsIn",        enabled = true,  speed = 3,  bezier = "overshot", style = "popin 95%" })
hl.animation({ leaf = "windowsOut",       enabled = true,  speed = 2,  bezier = "snappy",   style = "popin 90%" })
hl.animation({ leaf = "windowsMove",      enabled = true,  speed = 3,  bezier = "smooth",   style = "slide" })
hl.animation({ leaf = "border",           enabled = false, speed = 8,  bezier = "smooth" })
hl.animation({ leaf = "borderangle",      enabled = false, speed = 50, bezier = "smooth",   style = "loop" })
hl.animation({ leaf = "fade",             enabled = true,  speed = 4,  bezier = "smooth" })
hl.animation({ leaf = "workspaces",       enabled = true,  speed = 3,  bezier = "overshot", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true,  speed = 3,  bezier = "overshot", style = "slidevert" })
