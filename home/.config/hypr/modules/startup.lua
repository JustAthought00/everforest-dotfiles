-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function () 
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)
hl.on("hyprland.start", function () 
   hl.exec_cmd("awww-daemon")
   end)
hl.on("hyprland.start", function () 
   hl.exec_cmd("waybar")
   end)

hl.on("hyprland.start", function () 
   hl.exec_cmd("swaync")
   end)

-- Idle locking and clipboard history; run once at session startup.
hl.on("hyprland.start", function ()
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
