# Make another backup

## Capture the desktop again

From this repository, while logged into the desktop:

```bash
python3 scripts/snapshot.py --output "$HOME/everforest-snapshot-$(date +%Y%m%d-%H%M%S)"
```

Use a new, empty output folder. The snapshot tool copies only the listed desktop configuration directories and helper scripts, plus the active wallpaper when the wallpaper daemon is reachable. It excludes old backups, caches, logs, and bytecode. The restore tool, instructions, licences, and preview images are carried into the new folder.

Shell files are stored separately and remain optional during restoration. The installed package inventory is captured for reference. Wi-Fi profiles, paired-device databases, clipboard contents, browser profiles, and credentials are not collected.

Inspect the resulting folder before uploading it if you have since added personal data to any configuration file.

## Make a portable archive

Substitute the actual new snapshot folder name:

```bash
tar -czf everforest-backup.tar.gz -C "$HOME" everforest-snapshot-TIMESTAMP
sha256sum everforest-backup.tar.gz > everforest-backup.tar.gz.sha256
```

Keep a copy on another drive as well as GitHub.

## Publish this folder to GitHub

Create an empty **private** repository named `everforest-dotfiles` in the intended account. Do not initialise it with a README if using these first-push commands.

From the snapshot folder:

```bash
git init -b main
git add .
git -c user.name='Vivek S D' -c user.email='139540600+JustAthought00@users.noreply.github.com' \
  commit -m 'Back up Everforest Hyprland desktop'
git remote add origin https://github.com/JustAthought00/everforest-dotfiles.git
git push -u origin main
```

Authenticate using your usual GitHub method. No GitHub token is included in this snapshot. These commands create a local history and push the files; they do not create the GitHub repository itself.

If the repository already has commits, clone it first and copy the snapshot into that clone instead of replacing its history.

For later updates:

```bash
git status
git diff
git add .
git commit -m 'Update Everforest desktop backup'
git push
```

Use the snapshot script for a new capture first; editing the live desktop does not automatically update the backup folder. Preserve the new `manifest.json` alongside its matching payload files.
