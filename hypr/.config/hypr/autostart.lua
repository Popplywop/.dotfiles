-- ~/.config/hypr/autostart.lua
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- kanshi")
    hl.exec_cmd("uwsm app -- awww-daemon")
    hl.exec_cmd("uwsm app -- systemctl --user start hyprpolkitagent")
    hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
    hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
    -- hl.exec_cmd("uwsm app -- systemctl --user enable --now waybar.service")  -- replaced by quickshell bar
    -- hl.exec_cmd("uwsm app -- qs --path ~/.config/quickshell/bar")
end)

return true
