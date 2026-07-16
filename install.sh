#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  BransonCr dotfiles installer — Hyprland "productive Arch" rice
#  Usage:  ./install.sh            # do it
#          ./install.sh --check    # dry run, prints actions, changes nothing
# ─────────────────────────────────────────────────────────────
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_REPO="https://github.com/BransonCr/nvim.git"
DRY=0
[[ "${1:-}" == "--check" || "${1:-}" == "--dry-run" ]] && DRY=1

c() { printf '\033[%sm%s\033[0m' "$1" "$2"; }
info() { echo "$(c '1;35' '::') $*"; }
warn() { echo "$(c '1;33' '!!') $*" >&2; }
die()  { echo "$(c '1;31' 'xx') $*" >&2; exit 1; }
run()  { if [[ $DRY -eq 1 ]]; then echo "   $(c '2' "[dry] $*")"; else eval "$*"; fi; }

# ---- Guards ----------------------------------------------------------
[[ $EUID -eq 0 ]] && die "Run as your normal user, not root (it uses sudo where needed)."
command -v pacman >/dev/null || die "This installer is for Arch-based distros (pacman not found)."
[[ $DRY -eq 1 ]] && warn "DRY RUN — nothing will be installed or overwritten."

# ---- 1. AUR helper (paru) -------------------------------------------
ensure_paru() {
    command -v paru >/dev/null && return 0
    command -v yay  >/dev/null && { AUR=yay; return 0; }
    info "Installing paru (AUR helper)…"
    run "sudo pacman -S --needed --noconfirm base-devel git"
    run "git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin"
    run "cd /tmp/paru-bin && makepkg -si --noconfirm && cd -"
}
AUR=paru
ensure_paru

# ---- 2. Repo packages ------------------------------------------------
info "Installing official packages from packages.txt…"
mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' "$REPO/packages.txt")
run "sudo pacman -S --needed --noconfirm ${PKGS[*]}"

# ---- 3. AUR packages (one at a time, non-fatal) ---------------------
info "Installing AUR packages from packages-aur.txt…"
while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    run "$AUR -S --needed --noconfirm '$pkg'" || warn "AUR package '$pkg' failed — skipping."
done < "$REPO/packages-aur.txt"

# ---- 4. Config files (backup then copy) -----------------------------
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.config-backup-$STAMP"
info "Deploying configs (backups → $BACKUP)…"
run "mkdir -p '$HOME/.config' '$BACKUP'"
for src in "$REPO"/config/*/; do
    name="$(basename "$src")"
    dest="$HOME/.config/$name"
    [[ -e "$dest" ]] && run "mv '$dest' '$BACKUP/'"
    run "cp -r '$src' '$HOME/.config/'"
done
# loose $HOME dotfiles
for f in "$REPO"/home/.[!.]*; do
    [[ -e "$f" ]] || continue
    bn="$(basename "$f")"
    [[ -e "$HOME/$bn" ]] && run "mv '$HOME/$bn' '$BACKUP/'"
    run "cp '$f' '$HOME/$bn'"
done

# ---- 5. Wallpaper ----------------------------------------------------
info "Ensuring a wallpaper exists…"
run "mkdir -p '$HOME/.config/wallpapers'"
if [[ $DRY -eq 0 && ! -f "$HOME/.config/wallpapers/wall.png" ]]; then
    magick -size 3840x2160 \
        gradient:'#191724-#1f1d2e' "$HOME/.config/wallpapers/wall.png" \
        || warn "Couldn't generate wallpaper (is imagemagick installed?). Drop your own at ~/.config/wallpapers/wall.png"
else
    echo "   $(c '2' '[dry] generate ~/.config/wallpapers/wall.png (rose-pine gradient)')"
fi

# ---- 6. Neovim (your live repo) -------------------------------------
info "Setting up Neovim (BransonCr/nvim)…"
if [[ -d "$HOME/.config/nvim/.git" ]]; then
    info "  nvim is already a git repo — leaving it, run 'git -C ~/.config/nvim pull' to update."
else
    [[ -e "$HOME/.config/nvim" ]] && run "mv '$HOME/.config/nvim' '$BACKUP/'"
    run "git clone '$NVIM_REPO' '$HOME/.config/nvim'"
fi

# ---- 7. Display manager (ly) ----------------------------------------
info "Configuring ly display manager…"
run "sudo mkdir -p /etc/ly"
run "sudo cp '$REPO/etc/ly/config.ini' /etc/ly/config.ini"
# Disable whatever DM is active (effective on reboot; not --now so you keep your session)
if systemctl is-enabled display-manager.service >/dev/null 2>&1; then
    run "sudo systemctl disable display-manager.service"
fi
run "sudo systemctl enable ly.service"

# ---- 8. Shell + services --------------------------------------------
info "Setting default shell to zsh…"
[[ "${SHELL:-}" == *zsh ]] || run "sudo chsh -s '$(command -v zsh)' '$USER'" || warn "chsh failed — run it manually."

info "Enabling NetworkManager…"
run "sudo systemctl enable NetworkManager.service"

# ---- 9. GTK / cursor theme ------------------------------------------
info "Applying rose-pine GTK + cursor (best-effort)…"
run "gsettings set org.gnome.desktop.interface gtk-theme 'rose-pine' 2>/dev/null" || true
run "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null" || true
run "gsettings set org.gnome.desktop.interface cursor-theme 'BreezeX-RosePine-Linux' 2>/dev/null" || true

# ---- 10. NVIDIA sanity note -----------------------------------------
# (grep -c, not -q: -q closes the pipe early and SIGPIPEs lspci, which
#  trips pipefail and silently skips this whole check.)
nvidia_hits="$(lspci 2>/dev/null | grep -ci nvidia || true)"
if [[ "$nvidia_hits" -gt 0 ]] && ! grep -q 'nvidia_drm.modeset=1' /proc/cmdline 2>/dev/null; then
    warn "NVIDIA detected but 'nvidia_drm.modeset=1' is NOT in your kernel cmdline."
    warn "Add it to your bootloader (GRUB: GRUB_CMDLINE_LINUX_DEFAULT) or Hyprland may fail to start."
fi

echo
info "$(c '1;32' 'Done!')  Reboot to land in ly → Hyprland."
[[ $DRY -eq 1 ]] && warn "(That was a dry run — re-run without --check to apply.)"
