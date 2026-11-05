# Restore and rollback

## What the restore tool does

`restore.py` uses `manifest.json` to verify each selected source file before writing. A dry run creates no destination files. An applied restore copies the selected files, preserves executable permissions, backs up existing files, and records the operation in `state.json`.

It does not install packages, start daemons, change your login shell, reload Hyprland, restart SDDM, or sign you out. Log out and back in when you are ready for startup applications to run.

```bash
python3 restore.py --dry-run
python3 restore.py --apply
```

For a trial run into a disposable directory:

```bash
mkdir -p /tmp/everforest-trial
python3 restore.py --target-home /tmp/everforest-trial --dry-run
python3 restore.py --target-home /tmp/everforest-trial --apply
```

Keep the repository folder while restoring; the tool reads the manifest and bundled files beside it.

## Existing GTK directory symlinks

Some theme managers make `~/.config/gtk-4.0/assets` a link into `/usr/share/themes`. The restore tool refuses to write through a directory link outside your home. It lists affected paths during a dry run.

If this applies, move the existing GTK4 configuration aside first:

```bash
mv ~/.config/gtk-4.0 ~/.config/gtk-4.0.before-everforest-$(date +%Y%m%d-%H%M%S)
python3 restore.py --apply
```

That preserves the original directory and links; it does not modify the system theme. The backup contains regular, portable GTK4 files and the theme in `~/.local/share/themes`.

## Roll back an applied restore

Find the backup directory printed by the restore command:

```bash
ls -1 ~/.local/state/everforest-dotfiles/backups/
```

Substitute its timestamp below:

```bash
python3 restore.py --rollback "$HOME/.local/state/everforest-dotfiles/backups/TIMESTAMP" --dry-run
python3 restore.py --rollback "$HOME/.local/state/everforest-dotfiles/backups/TIMESTAMP" --apply
```

The tool restores previous files and removes files that it created. Empty directories can remain. If a file has been edited since the restore, rollback stops rather than silently discarding that edit; save your changes and compare them with the snapshot first.

The optional SDDM installer keeps its own system backup under `/var/lib/sddm/theme-backups/`. It is separate from user-file rollback. Review the backed-up selection files before restoring them. Removing the newly added selection file returns control to the remaining SDDM configuration:

```bash
sudo rm /etc/sddm.conf.d/90-everforest.conf
```

If that file existed before installing, restore its backed-up version instead of removing it. Changes take effect at the next login; restarting SDDM would end the current graphical session.

## Optional Zsh and Powerlevel10k

The default restore preserves your existing `.zshrc` and adds only the PATH helper. To reproduce the captured prompt too, install its framework and theme first:

```bash
sudo pacman -S --needed zsh git eza
```

If Oh My Zsh is not already installed:

```bash
git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
```

If Powerlevel10k is not already installed:

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

Then restore the shell files:

```bash
python3 restore.py --include-shell --dry-run
python3 restore.py --include-shell --apply
```

Optionally choose Zsh as your login shell:

```bash
chsh -s /usr/bin/zsh
```

Open a new terminal. Use `p10k configure` if you want to adjust the prompt for a different display or font. Shell history and framework caches are not part of this snapshot.

## GTK and icons

The active GTK theme is bundled, so you do not need to rebuild it from the AUR:

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Everforest-Green-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
nwg-look -a
sudo ~/.local/bin/papirus-folders -C green --theme Papirus-Dark
```

Dolphin reads its icon selection from `~/.config/kdeglobals`; the visual settings are included. Reopen applications if they still display the old icons.
