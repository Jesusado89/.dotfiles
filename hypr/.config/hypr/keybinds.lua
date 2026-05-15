-- ============================================================================
-- Keybinds — main bindings, resize submap, and reactive behaviors.
-- ============================================================================

local programs = require("programs")
local mainMod  = "SUPER"


--------------------------
---- APPS / SHORTCUTS ----
--------------------------

-- Dropdown terminal
hl.bind("F12", hl.dsp.exec_cmd(programs.scriptsDir .. "dropdown.sh"))

-- Apps
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd(programs.waybarLaunch))
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd(programs.menu))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",         hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + M",         hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd(programs.clipboardMenu))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd(programs.notifyToggle))
hl.bind(mainMod .. " + Tab",       hl.dsp.focus({ workspace = "previous" }))

-- System
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd(programs.lockscreen))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Window info — Lua introspection in action
hl.bind(mainMod .. " + I", function()
    local w = hl.get_active_window()
    if not w then return end
    hl.notification.create({
        text = string.format("class: %s\ntitle: %s",
            tostring(w.class or "?"),
            tostring(w.title or "?")),
        timeout = 4000,
        icon    = "info",
    })
end)

-- Toggle layout between dwindle and scrolling
hl.bind(mainMod .. " + ALT + L", function()
    local current = hl.get_config("general.layout")
    if current == "scrolling" then
        hl.config({ general = { layout = "dwindle" } })
    else
        hl.config({ general = { layout = "scrolling" } })
    end
end)


-----------------------------
---- SCROLLING LAYOUT    ----
-----------------------------

-- Move the layout horizontally between columns
hl.bind(mainMod .. " + ALT + left",  hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + ALT + right", hl.dsp.layout("move +col"))

-- Swap current column with neighbor (wraps around)
hl.bind(mainMod .. " + ALT + SHIFT + left",  hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + ALT + SHIFT + right", hl.dsp.layout("swapcol r"))

-- Resize current column
hl.bind(mainMod .. " + ALT + CTRL + left",  hl.dsp.layout("colresize -0.1"))
hl.bind(mainMod .. " + ALT + CTRL + right", hl.dsp.layout("colresize +0.1"))

-- Cycle preconfigured column widths
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(programs.scriptsDir .. "toggle-column-size.sh"))

-- 0.55 scrolling dispatchers
hl.bind(mainMod .. " + ALT + e", hl.dsp.layout("expel"))                  -- move window to its own column
hl.bind(mainMod .. " + ALT + i", hl.dsp.layout("consume_or_expel prev"))  -- consume into prev, or expel
hl.bind(mainMod .. " + ALT + p", hl.dsp.layout("promote"))                -- promote window to a new column
hl.bind(mainMod .. " + ALT + f", hl.dsp.layout("fit active"))             -- fit active column on screen


-----------------------
---- RESIZE SUBMAP ----
-----------------------

-- SUPER + R enters resize mode. h/j/k/l or arrows to resize, escape to exit.
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    local step = 40

    -- Arrows
    hl.bind("right", hl.dsp.window.resize({ x =  step, y =  0,    relative = true }), { repeating = true })
    hl.bind("left",  hl.dsp.window.resize({ x = -step, y =  0,    relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x =  0,    y = -step, relative = true }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ x =  0,    y =  step, relative = true }), { repeating = true })

    -- HJKL
    hl.bind("l",     hl.dsp.window.resize({ x =  step, y =  0,    relative = true }), { repeating = true })
    hl.bind("h",     hl.dsp.window.resize({ x = -step, y =  0,    relative = true }), { repeating = true })
    hl.bind("k",     hl.dsp.window.resize({ x =  0,    y = -step, relative = true }), { repeating = true })
    hl.bind("j",     hl.dsp.window.resize({ x =  0,    y =  step, relative = true }), { repeating = true })

    -- Exit
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)


-------------------------
---- MOUSE / FOCUS   ----
-------------------------

-- Mouse drag/resize (SUPER + LMB = drag, SUPER + RMB = resize)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))

-- Move active window
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left"  }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up"    }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down"  }))


--------------------
---- WORKSPACES ----
--------------------

for i = 1, 7 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Special workspaces
hl.bind(mainMod .. " + S",             hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S",     hl.dsp.window.move({ workspace = "special:magic" }))

-- Scratchpad terminal (SUPER + ~)
hl.bind(mainMod .. " + grave",         hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Mouse wheel cycles workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))


---------------------
---- SCREENSHOTS ----
---------------------

hl.bind("Print",         hl.dsp.exec_cmd("hyprshot -m window -o " .. programs.screenshotDir))
hl.bind("CTRL + Print",  hl.dsp.exec_cmd("hyprshot -m output -o " .. programs.screenshotDir))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))


--------------------
---- MULTIMEDIA ----
--------------------

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


-- ============================================================================
-- REACTIVE BEHAVIORS — what Lua makes possible
-- ============================================================================


-- Picture-in-Picture: many sites change a window's title to "Picture-in-Picture"
-- after the window already exists. The static rule in rules.lua only catches
-- windows that open with that title; this catches the rest.
hl.on("window.title", function(w)
    if w and w.title == "Picture-in-Picture" then
        hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
        hl.dispatch(hl.dsp.window.pin({ window = w }))
    end
end)


-- Monitor connect/disconnect notifications
hl.on("monitor.added", function(m)
    hl.notification.create({
        text    = "Monitor connected: " .. (m and m.name or "?"),
        timeout = 2500,
        icon    = "ok",
    })
end)

hl.on("monitor.removed", function(m)
    hl.notification.create({
        text    = "Monitor disconnected: " .. (m and m.name or "?"),
        timeout = 2500,
        icon    = "warning",
    })
end)


-- Do-Not-Disturb toggle: silences notifications, disables animations,
-- and dims the screen slightly for a calmer focus environment.
local dnd_enabled = false

hl.bind(mainMod .. " + SHIFT + D", function()
    dnd_enabled = not dnd_enabled

    if dnd_enabled then
        hl.config({ animations = { enabled = false } })
        hl.exec_cmd("swaync-client -dn")
        hl.notification.create({ text = "DND on",  timeout = 1200, icon = "info" })
    else
        hl.config({ animations = { enabled = true  } })
        hl.exec_cmd("swaync-client -df")
        hl.notification.create({ text = "DND off", timeout = 1200, icon = "ok" })
    end
end)
