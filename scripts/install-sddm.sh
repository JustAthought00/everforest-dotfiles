#!/usr/bin/env bash
# Run as your normal user; sudo is used only for the optional system theme.
set -euo pipefail
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [[ ${1:-} != --apply ]]; then
    echo 'Preview only: install the bundled Everforest SDDM theme and select it for the NEXT login.'
    echo 'Run: bash scripts/install-sddm.sh --apply'
    exit 0
fi
if ! command -v sddm-greeter-qt6 >/dev/null; then
    echo 'Install sddm and qt6-declarative first.' >&2; exit 1
fi
stamp=$(date +%Y%m%d-%H%M%S)
backup_dir="/var/lib/sddm/theme-backups/everforest-restore-$stamp"
sudo mkdir -p "$backup_dir"
for item in /etc/sddm.conf /etc/sddm.conf.d /usr/share/sddm/themes/everforest-minimal; do
    if [[ -e "$item" ]]; then sudo cp -a --parents "$item" "$backup_dir/"; fi
done
sudo install -d -m 755 /usr/share/sddm/themes/everforest-minimal /etc/sddm.conf.d
for file in "$repo_dir"/system/usr/share/sddm/themes/everforest-minimal/*; do
    sudo install -m 644 "$file" /usr/share/sddm/themes/everforest-minimal/
done
sudo install -m 644 "$repo_dir/system/etc/sddm.conf.d/90-everforest.conf" /etc/sddm.conf.d/90-everforest.conf
printf 'Theme installed. Backup: %s\n' "$backup_dir"
echo 'SDDM was not restarted. An existing /etc/sddm.conf can override the selected theme; review its [Theme] section.'
