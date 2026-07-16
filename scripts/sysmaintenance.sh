#!/usr/bin/env bash
# Monthly Arch housekeeping. Read it before you run it.
#   ./sysmaintenance.sh            # clean caches, orphans, pacdiff check
#   ./sysmaintenance.sh --upgrade  # also full system upgrade
set -euo pipefail

AUR="$(command -v paru || command -v yay || true)"
ask() { read -rp "$1 [y/N] " a; [[ "$a" =~ ^[Yy]$ ]]; }

echo ":: Arch maintenance"

if [[ "${1:-}" == "--upgrade" ]]; then
    echo ":: Full upgrade…"
    sudo pacman -Syu
    [[ -n "$AUR" ]] && "$AUR" -Sua || true
fi

# Trim the package cache to the last 2 versions
if command -v paccache >/dev/null; then
    echo ":: Trimming pacman cache (keep 2)…"
    sudo paccache -rk2
    sudo paccache -ruk0   # drop uninstalled
else
    echo "!! paccache missing (install pacman-contrib) — skipping cache trim."
fi

# Remove orphaned dependencies
orphans="$(pacman -Qtdq || true)"
if [[ -n "$orphans" ]]; then
    echo ":: Orphaned packages:"; echo "$orphans"
    ask "Remove them?" && sudo pacman -Rns $orphans
else
    echo ":: No orphans."
fi

# Merge leftover .pacnew/.pacsave files
if command -v pacdiff >/dev/null; then
    echo ":: Checking for .pacnew/.pacsave (pacdiff)…"
    sudo DIFFPROG="${DIFFPROG:-nvim -d}" pacdiff
fi

# Failed systemd units
echo ":: Failed systemd units:"
systemctl --failed --no-legend || true

echo ":: Done. A reboot is a good idea after big upgrades."
