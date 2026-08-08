-- ~/.config/hypr/windowrules.lua
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
    -- Ignore maximize requests from all apps
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    -- hyprland-run floating terminal (bottom-left)
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    -- Update terminal launched by the quickshell UpdatesWidget
    name  = "updates-terminal",
    match = { class = "wezterm-updates" },

    float  = true,
    size   = "1200 700",
    center = true,
})

hl.window_rule({
    -- Yazi floating file manager (Super+F)
    name  = "yazi",
    match = { class = "yazi" },

    float  = true,
    size   = "1400 800",
    center = true,
})

return true
