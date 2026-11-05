# Snapshot details

Captured on 5 November 2026, on Arch Linux.

## Captured environment

- Hyprland 0.57.1, using `hyprland.lua` and Lua modules.
- Rofi 2.0.0; custom desktop menus specify their own theme files.
- SwayNC 0.12.6, Waybar 0.15.0, Hyprlock 0.9.7, Hypridle 0.1.8.
- SDDM 0.21.0 with a Qt 6 theme.
- Intel UHD 620 graphics; two-display monitor settings.

The complete package inventory is in `packages/installed-versions.txt`. `packages/official.txt` is the curated installation list; it is intentionally much smaller than the inventory.

## Portability adjustments

The snapshot materialises GTK theme symlinks as regular files, bundles the active theme under the user's local share directory, and saves the captured current wallpaper inside the wallpaper collection. Launcher artwork missing from the active Rofi directory was copied from the existing local launcher source checkout so those themes are self-contained.

Only visual KDE groups are included. KDE file-dialog locations, application history, saved networks, paired-device databases, command history, clipboard databases, and browser profiles are excluded.

## Machine-specific values to review

- Monitor names, resolutions, and positions in `modules/monitors.lua`.
- The network interface name `wlo1` in Waybar.
- Default apps in `modules/programs.lua`; Dolphin is an optional package.
- ALSA `Master` and `Capture` names in the notification-button commands.
- The preferred Bluetooth device name in Waybar; no pairing secrets are included.

## Existing configuration limitations

The captured Kitty file requests GeistMono Nerd Font even though that font was not installed. The restore documentation includes a command to use JetBrainsMono Nerd Font instead. Some existing Kitty options may depend on the Kitty version; the original file is preserved rather than silently rewritten.

The wallpaper daemon's runtime cache is not exported. Apply `saved-current.jpg` once after restoring; the daemon remembers the selection afterward.

The SDDM theme was previewed and tested with mock login actions and as the unprivileged SDDM account. A real sign-out/sign-in was not performed during setup. Authentication continues to use the system's existing PAM configuration.

GTK4 applications that enforce their own appearance can ignore some GTK theme settings. The custom menus, bar, notification panel, and lock/login screens each have their own captured styles.

## Checks performed for this backup

- Manifest hashes checked against captured files.
- Restore dry run, apply, and rollback tested in a disposable home directory.
- Existing files preserved by the restore backup.
- Source corruption and external destination-directory symlinks rejected before writes.
- Lua and helper-script syntax checked.
- Package names checked against the local Arch package databases.
- No credentials or runtime histories intentionally collected.
