# Command reference

## Check and reload

```bash
hyprctl reload
hyprctl configerrors
hyprctl monitors
hyprctl binds
hyprctl animations
swaync-client -R       # reload notification configuration
swaync-client -rs      # reload notification CSS
pkill -USR2 -x waybar  # reload Waybar configuration and CSS
```

Avoid restarting the whole login manager to reload desktop styling.

## Wallpaper gallery

```bash
wallpaper
wallpaper --random
wallpaper "/path/to/image with spaces.jpg"
awww query
```

Add images under `~/.local/share/wallpapers/`, `~/Pictures/Wallpapers/`, or `~/Wallpapers/`. The gallery also includes the current image. The `awww-daemon` startup entry restores its cached image at future logins.

If your terminal cannot find `wallpaper`, open a new terminal or load the small PATH helper:

```bash
source ~/.config/everforest/path.zsh
```

## Clipboard history

```bash
~/.config/hypr/scripts/clipboard-menu
cliphist wipe
```

Select an entry, then paste normally. Text and images are stored by two `wl-paste` watchers started once per login. The history database is excluded from the backup.

To start the watchers manually in a new running session, first check that they are not already running:

```bash
pgrep -a wl-paste
```

Start only the missing watcher:

```bash
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
```

## Lock, idle, and session controls

```bash
hyprlock
~/.config/hypr/scripts/power-menu
pgrep -a hypridle
```

Idle settings live in `~/.config/hypr/hypridle.conf`. They lock after 300 seconds, turn displays off after 600, and respect app idle inhibitors. No automatic suspend timer is configured.

After editing idle settings, restart only Hypridle:

```bash
pkill -x hypridle
hypridle &
```

The lock screen accepts your existing Linux login password. Its media widget uses `playerctl`; an app must expose playback controls for it to appear.

## Wi-Fi and Bluetooth

```bash
~/.config/hypr/scripts/wifi-picker
nmcli device status
nmcli device wifi list
blueman-manager
bluetoothctl devices Connected
```

Saved Wi-Fi profiles and passwords are managed by NetworkManager and are not exported. Reconnect manually on a restored system. The graphical picker supports ordinary personal Wi-Fi passwords; enterprise and WEP configuration use its Advanced settings button.

Bluetooth battery readings come from the device. A missing reading is displayed as Connected rather than a guessed percentage. The bar labels audio volume separately.

## Audio and media

```bash
pavucontrol
wpctl get-volume @DEFAULT_AUDIO_SINK@
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
playerctl status
playerctl play-pause
```

The notification buttons preserve the captured ALSA commands:

```bash
amixer set Master toggle
amixer set Capture toggle
```

If another machine has no `Master` or `Capture` ALSA control, replace those two button commands in `~/.config/swaync/config.json` with the corresponding `wpctl` mute commands above.

## Screenshots, colours, and appearance

```bash
hyprshot -m region
hyprpicker -a
nwg-look
```

The screenshot button closes the notification panel before starting selection. For font changes, edit Kitty's `font_family` and Rofi's shared theme at `~/.config/rofi/everforest/base.rasi`.

The captured Kitty config requests GeistMono Nerd Font, which was not installed at capture time. To use the bundled setup's installed Nerd Font instead:

```bash
sed -i 's/^font_family.*/font_family JetBrainsMono Nerd Font/' ~/.config/kitty/kitty.conf
```

## Login theme

Preview without logging out:

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/everforest-minimal
```

The startup login screen uses SDDM; the in-session lock screen uses Hyprlock. Their configuration files are separate.
