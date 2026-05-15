-- ============================================================================
-- Programs — the apps you launch via keybinds.
-- Edit here, not in keybinds.lua.
-- ============================================================================

return {
    terminal      = "kitty",
    fileManager   = "nemo",
    menu          = "fuzzel",
    browser       = "qutebrowser",
    lockscreen    = "swaylock",
    clipboardMenu = "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy",
    notifyToggle  = "swaync-client -t -sw",
    screenshotDir = os.getenv("HOME") .. "/Screenshots/",
    scriptsDir    = os.getenv("HOME") .. "/.config/hypr/scripts/",
    waybarLaunch  = os.getenv("HOME") .. "/.config/waybar/scripts/launch.sh",
}
