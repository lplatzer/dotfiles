# Tiling WM Cheatsheet — AeroSpace (macOS) · Hyprland (Linux)

**Mod = `Alt`** on both machines. Keybinds are identical across OSes; the only
deliberate difference is the launcher, which sits on the **Cmd/Super** key so it
matches your keyboard remap.

| Launcher | macOS | Linux |
|---|---|---|
| App launcher | `Cmd + Space` (Alfred) | `Super + Space` (walker) |

---

## Apps

| Action | Keys |
|---|---|
| New terminal (Ghostty) | `Alt + Enter` |
| Launcher | `Cmd/Super + Space` |

## Focus

| Action | Keys |
|---|---|
| Focus left | `Alt + H` |
| Focus down | `Alt + J` |
| Focus up | `Alt + K` |
| Focus right | `Alt + L` |

## Move window

| Action | Keys |
|---|---|
| Move left | `Alt + Shift + H` |
| Move down | `Alt + Shift + J` |
| Move up | `Alt + Shift + K` |
| Move right | `Alt + Shift + L` |

## Window state

| Action | Keys |
|---|---|
| Close window | `Alt + Q` |
| Fullscreen | `Alt + F` |
| Toggle floating / tiling | `Alt + Shift + Space` |
| Shrink / grow | `Alt + -` / `Alt + =` |
| Drag to move / resize | hold `Alt` + left / right mouse |

## Layout

| Action | macOS (AeroSpace) | Linux (Hyprland) |
|---|---|---|
| Toggle split orientation | `Alt + /` (tiles h/v) | `Alt + /` (togglesplit) |
| Accordion / pseudotile | `Alt + ,` | `Alt + ,` (pseudo) |

## Workspaces

| Action | Keys |
|---|---|
| Go to workspace 1–10 | `Alt + 1` … `Alt + 9`, `Alt + 0` |
| Move window to workspace 1–10 | `Alt + Shift + 1` … `9`, `0` |
| Back-and-forth (last workspace) | `Alt + Tab` |
| Send workspace to next monitor | `Alt + Shift + Tab` |

## macOS service mode (AeroSpace)

Enter with **`Alt + Shift + ;`**, then:

| Key | Action |
|---|---|
| `Esc` | Reload config & exit mode |
| `R` | Reset layout (flatten tree) |
| `F` | Toggle floating / tiling |
| `Backspace` | Close all windows but current |
| `Alt + Shift + H/J/K/L` | Join window with neighbour |

## Linux-only (Hyprland)

| Action | Keys |
|---|---|
| Quit Hyprland | `Alt + Shift + E` |
| Lock (if hyprlock installed) | `Alt + Esc` *(commented by default)* |
| Region screenshot (grim+slurp) | `Print` *(commented by default)* |

---

### Notes
- **Quit an app** is still the native `Cmd + Q` on macOS — `Alt + Q` only closes
  the focused window in the WM.
- Workspaces are numbered **1–10** on both machines for parity.
- Config lives in `~/.aerospace.toml` (macOS) and `~/.config/hypr/` (Linux);
  both are managed by chezmoi in `~/.local/share/chezmoi`.
