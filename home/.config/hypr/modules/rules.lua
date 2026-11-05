-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
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

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Utility windows should open centred without rearranging tiled workspaces.
hl.window_rule({
    name = "floating-settings-tools",
    match = { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|Pavucontrol|wifi-manager|nm-connection-editor|Nm-connection-editor|blueman-manager|Blueman-manager|nwg-look)$" },
    float = true,
    center = true,
    size = "800 520",
})

-- Graphical Wi-Fi chooser opened from the notification panel.
hl.window_rule({
    name = "graphical-wifi-picker",
    match = { class = "^(local[.]everforest[.]WifiPicker|wifi-picker)$" },
    float = true,
    center = true,
    size = "520 560",
})
