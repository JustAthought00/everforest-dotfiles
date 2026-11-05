# Backup validation

Validated on 5 November 2026.

| Check | Result |
|---|---|
| Restore dry run | No files created or modified in the test home |
| Restore apply | All desktop payload checksums and file permissions matched |
| Existing configuration | Original files saved before replacement |
| Rollback | Original Hyprland file and shell file recovered; created files removed |
| Corrupt snapshot | Rejected before writing destination files |
| External directory symlink | Rejected before writing through it |
| Lua / Python / Bash | Syntax checks passed |
| Arch package lists | All official package names found in the local package databases |
| Sensitive-file scope | Browser profiles, network credentials, clipboard data and auth stores excluded |
| Secret-pattern scan | No supplied password, common GitHub token prefix, AWS access-key pattern or private-key header found |
| Current wallpaper | Read from the active daemon and copied into the collection |

These are restoration-tool and file-integrity checks. A fresh Arch installation was not performed, and no real SDDM authentication attempt was made. The running desktop was not restored over or restarted while creating the backup.

`manifest.json` verifies the restorable payload. `SHA256SUMS` verifies the files in this folder as delivered. The separate archive checksum verifies the compressed download.
