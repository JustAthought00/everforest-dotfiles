# Hyprland configuration

hyprland.lua loads the Lua files in modules/ in order.

- monitors.lua: displays, resolutions, scaling and positions
- programs.lua: default terminal, file manager and launcher
- startup.lua: programs launched when Hyprland starts
- environment.lua: environment variables
- permissions.lua: optional permission settings (currently commented out)
- appearance.lua: gaps, borders, rounding, shadows and blur
- animations.lua: animation curves and speeds
- layouts.lua: tiling layouts and optional smart gaps
- misc.lua: wallpaper and logo behaviour
- input.lua: keyboard, mouse, touchpad and gestures
- keybindings.lua: shortcuts, workspaces, media and brightness keys
- rules.lua: window and layer rules

After editing, run `hyprctl reload` and check `hyprctl configerrors`.
To add a module, create modules/name.lua and add require("modules.name")
to hyprland.lua in the desired load order. Modules have separate local
variables; use require("modules.programs") to access shared app defaults.

Hyprlock uses hyprlock.conf and scripts/ independently.
SwayNC uses ~/.config/swaync/ independently.

## Everyday tools

- Super+W: wallpaper picker
- Super+Shift+V: clipboard history (select an item, then paste normally)
- Super+X: power menu; logout, restart, and shutdown require confirmation
- Super+L: lock screen

hypridle.conf controls idle locking (5 minutes) and display power (10 minutes).
Sleep also requests the lock; media/presentation idle inhibitors are respected.
No automatic suspend timeout is configured.
Clipboard text and image watchers start once per login via modules/startup.lua.
Run `cliphist wipe` to clear clipboard history.
Helper scripts live in scripts/; settings tools float at 800x520.
