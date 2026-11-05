#!/usr/bin/env bash
set -euo pipefail
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if ! command -v pacman >/dev/null; then echo 'This package list targets Arch Linux.' >&2; exit 1; fi
mapfile -t desktop_packages < <(sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$repo_dir/packages/official.txt")
if [[ ${1:-} != --apply ]]; then
    printf 'Preview: sudo pacman -Syu --needed'; printf ' %q' "${desktop_packages[@]}"; printf '\n'
    echo 'Run with --apply to update Arch and install these desktop packages.'
    exit 0
fi
sudo pacman -Syu --needed "${desktop_packages[@]}"
