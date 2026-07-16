# BransonCr's dotfiles

A plug-and-play **Hyprland** rice for Arch — the "productive Arch" stack from
[Oscar's video](https://www.youtube.com/watch?v=o03_cfOnl84) /
[kurealnum/dotfiles](https://github.com/kurealnum/dotfiles), rebuilt on **Wayland**
so you get real Hyprland animations, and wired to **my** keybinds + Neovim.

![theme: rose-pine](https://img.shields.io/badge/theme-rose--pine-c4a7e7)

## Install (fresh Arch box)

```bash
git clone https://github.com/BransonCr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --check   # dry run — see exactly what it will do
./install.sh           # do it, then reboot
```

`install.sh` installs packages (pacman + AUR via paru), backs up any existing
configs to `~/.config-backup-<date>/`, copies these configs into place, clones
my Neovim config, and switches the display manager to **ly**. Reboot → ly → Hyprland.

## The stack

| Role | Tool |
|------|------|
| Compositor / WM | **Hyprland** (animations: balanced) |
| Display manager | **ly** |
| Bar | **Waybar** (minimal) |
| Launcher | **rofi** (wayland) |
| Terminal | **kitty** |
| Notifications | **dunst** |
| Wallpaper | **hyprpaper** |
| Lock / idle | **hyprlock** + **hypridle** |
| Blue-light | **hyprsunset** |
| Screenshots | **grim + slurp + swappy** |
| Clipboard | **cliphist** |
| Files | **nnn** (TUI) + **thunar** (GUI) |
| GTK themes | **nwg-look** + rose-pine-gtk |
| Shell | **zsh** + starship |
| Editor | **Neovim** → [BransonCr/nvim](https://github.com/BransonCr/nvim) |
| Theme | **rose-pine** everywhere |

## Keybinds (Super = Mod)

| Keys | Action |
|------|--------|
| `Super`+`T` | terminal (kitty) |
| `Super`+`E` / `Super`+`Shift`+`E` | files (thunar / nnn) |
| `Super`+`C` | editor (nvim) |
| `Super`+`B` | browser |
| `Super`+`A` | app launcher · `Super`+`Tab` window switcher |
| `Super`+`Q` | close · `Super`+`W` float · `Super`+`F` fullscreen |
| `Super`+`arrows` | focus · `+Shift` resize · `+Shift+Ctrl` move |
| `Super`+`1..0` | workspace · `+Shift` move window there |
| `Super`+`S` | scratchpad |
| `Super`+`V` | clipboard history |
| `Super`+`P` | region screenshot · `Print` full · `Super`+`Shift`+`P` color pick |
| `Super`+`L` | lock · `Ctrl`+`Alt`+`Del` logout menu |

Full list: `config/hypr/keybindings.conf`.

## Notes

- **NVIDIA**: needs `nvidia_drm.modeset=1` on the kernel cmdline — the installer warns if it's missing.
- **Monitors** are hardcoded (dual 1080p) in `config/hypr/monitors.conf` — edit for new hardware (`hyprctl monitors`).
- **Neovim** is cloned live so you can still `git push` from `~/.config/nvim`.
- Change apps in one place: the `$term`/`$editor`/`$browser` vars at the top of `config/hypr/hyprland.conf`.
