# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

**挑挑拣拣 (Pick Photo Helper)** — a single-file Python tool for iterative photo selection. Users browse images in [Loupe](https://apps.gnome.org/Loupe/) (GNOME image viewer), toggle favorites with a global shortcut, and advance through successive rounds of refinement. Each round lives in a `layer{N}/` directory; selections are tracked via symlinks (no database).

## Key Architecture

### Filesystem-as-database
- **Layer 0** = source images in the working directory (`BASE_DIR`).
- **Layer N** (`layer{N}/`) = symlinks to images selected in layer N-1.
- To "select" an image: create a symlink `layer{N+1}/<basename>` → `<resolved-path>`.
- To "deselect": unlink it.
- `images_of(layer)` — glob `*.jpg` in the layer's directory.
- `selected_of(layer)` — images in layer N whose basename has a symlink in `layer{N+1}/`.

### Global keyboard shortcuts (dconf/gsettings)
- Python registers keybindings via `dconf write` + `gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings`.
- Each shortcut runs `python3 <script> --cmd <single-char-code>` which writes a char to a named FIFO (`/tmp/image_filter_cmd`).
- Four actions: `N` (next layer), `P` (prev layer), `T` (toggle like), `A` (like all).
- On exit, bindings are unregistered and dconf keys reset.

### Event loop (poll + FIFO)
- A `select.poll()` loop reads the FIFO non-blocking with 500ms timeout.
- Each tick also checks whether Loupe's systemd scope is still alive (`systemctl --user is-active`).
- When the user closes Loupe, the loop detects it and exits cleanly.

### Window title reading (AT-SPI)
- To get the current image filename when toggling (`Ctrl+Space`), the script reads Loupe's window title via `Atspi` (GNOME accessibility API).
- `get_loupe_filename()` iterates the desktop's app list looking for a "loupe" app, then reads its window title.
- Falls back to warning if unavailable.

### Process lifecycle
- Loupe is launched via `systemd-run --user --scope --unit=pick_photo_helper` → creates a systemd scope unit for the entire loupe process tree.
- `kill_loupe()` stops the scope; `viewer_alive()` checks if `pick_photo_helper.scope` is active.
- When advancing layers, the old loupe is killed and a new one opens on the first image of the next layer.

### Desktop-launch fallback
- `ensure_terminal()` checks `sys.stdout.isatty()`.
- If not in a terminal (double-click), re-launches self in `gnome-terminal`, `kgx`, `konsole`, `xfce4-terminal`, `lxterminal`, or `xterm` (in order) and exits.
- If no terminal is found, shows a `zenity` error dialog.
- `--from-desktop` flag keeps the terminal open at exit (`input("\n  按 Enter 关闭窗口...")`).

## Running

```bash
# In a directory with .jpg files:
python3 pick_photo_helper.py

# Help:
python3 pick_photo_helper.py --help
```

## Dependencies (system packages)

- **loupe** — GNOME image viewer (`gnome-loupe`)
- **systemd** — `systemd-run`, `systemctl --user` for scope lifecycle
- **AT-SPI** — `at-spi2-core`, Python `PyGObject` (`gi.repository.Atspi`)
- **gsettings/dconf** — GNOME settings daemon
- **notify-send** — `libnotify`
- **zenity** — optional, used for error dialog when no terminal found

## Code Map

| Function / Section | Purpose |
|---|---|
| `register_keybindings()` / `unregister_keybindings()` | Install/remove dconf global shortcuts |
| `images_of(layer)` / `selected_of(layer)` | Filesystem queries for a layer |
| `do_toggle()` / `do_like_all()` | Like/toggle/unlike logic |
| `do_next_layer()` / `do_prev_layer()` | Move forward/backward through layers |
| `get_loupe_filename()` / `resolve_filename_in_layer()` | AT-SPI bridge: map window title → image path |
| `open_image()` / `kill_loupe()` / `viewer_alive()` | systemd scope lifecycle for loupe |
| `ensure_terminal()` / `send_fifo_command()` | Desktop launch support / IPC |
| `main()` poll loop | Event loop: read FIFO + check loupe liveness |

## Patterns & Gotchas

- **State is in a plain dict** (`current_layer`, `current_index`, `waiting_for_loupe`, `loupe_wait_cycles`). All mutators return the updated dict (functional style).
- **Layer 0 has no `layer0/` directory** — images come from `BASE_DIR` directly. Layers 1+ use `layer{N}/` directories.
- **Symlinks, not copies** — `selected_of()` checks for symlink existence. `do_like_all()` deletes and recreates the next layer directory.
- **Loupe launch timeout** — max 30 poll cycles × 500ms = 15 seconds. After timeout the program exits.
- **FIFO cleanup** — removed on normal exit. If the script crashes, stale `/tmp/image_filter_cmd` is cleaned at next start.
- **No tests exist** — the project is a personal utility script.

## Security / Side Effects

- Modifies dconf/gsettings (global keybindings) at startup and cleanup.
- Creates symlinks in `layer{N}/` subdirectories.
- Kills `pick_photo_helper.scope` systemd unit.
- Creates/removes `/tmp/image_filter_cmd` FIFO.
- Only scans for `*.jpg` files in `BASE_DIR`.
