# Tiling WM Cheatsheet — AeroSpace (macOS) · Hyprland (Linux)

**WM mod = HYPER** = `Ctrl+Alt+Cmd` (macOS) / `Ctrl+Alt+Super` (Linux), emitted by
a dedicated ZSA thumb key. Shift is deliberately NOT part of Hyper, so it stays
free for the "move/shifted" variants. Keybinds are identical across both OSes.
Config is chezmoi-managed: `~/.aerospace.toml`, `~/.config/hypr/`.

> Oryx: map the thumb key to **Left Ctrl + Left Alt + Left GUI**. Do **not** use
> QMK `KC_HYPR` — that includes Shift and would break the move binds.

| Launcher (bare Cmd/Super, not Hyper) | macOS | Linux |
|---|---|---|
| App launcher | `Cmd + Space` (Alfred) | `Super + Space` (walker) |

---

## Apps

| Action | Keys |
|---|---|
| Terminal (Rex) | `Hyper + Enter` |
| Launcher | `Cmd/Super + Space` |

## Focus

| Action | Keys |
|---|---|
| Focus left / down / up / right | `Hyper + H` / `J` / `K` / `L` |

## Move window

| Action | Keys |
|---|---|
| Move left / down / up / right | `Hyper + Shift + H` / `J` / `K` / `L` |

## Window state

| Action | Keys |
|---|---|
| Close window | `Hyper + Q` |
| Fullscreen | `Hyper + F` |
| Toggle floating / tiling | `Hyper + Shift + Space` |
| Shrink / grow (hold to repeat) | `Hyper + -` / `Hyper + =` |
| Shrink / grow the other axis (macOS) | `Hyper + Shift + -` / `Hyper + Shift + =` |
| Drag to move | macOS: `Ctrl + Cmd` + drag anywhere in the window (needs a re-login once); Linux: `Hyper` + left mouse |
| Drag to resize | macOS: drag the edge between two tiles; Linux: `Hyper` + right mouse |

## Sizes (macOS)

Fractions of the screen, so a key gives the same split on the 49" ultrawide and
the MacBook screen. A lone window always fills the screen; these act once it
has a neighbour in its row, and only in tiles (a notification says so otherwise).
Helper: `aerospace-desk size`.

| Width of the focused window | Keys |
|---|---|
| 1/4 · 1/3 · 1/2 · 2/3 · 3/4 | `Hyper + Z` · `X` · `C` · `V` · `B` |
| Even out all windows | `Hyper + E` |

## Monitors (macOS)

| Action | Keys |
|---|---|
| Focus next monitor | `Hyper + M` |
| Move window to next monitor (and follow) | `Hyper + Shift + M` |

## Layout

| Action | macOS (AeroSpace) | Linux (Hyprland) |
|---|---|---|
| Toggle split orientation | `Hyper + /` (also leaves accordion) | `Hyper + /` (togglesplit) |
| Accordion / pseudotile | unbound (too easy to hit by mistake) | `Hyper + ,` (pseudo) |
| Stack toggle (like a group) | `Hyper + T`: the column shows one window at a time, `Hyper + J/K` cycles | — |

## Role workspaces (macOS, aerospace-desk)

Apps are sorted by role, and the arrangement follows the screens attached:

| Workspace | Apps |
|---|---|
| 1 web and research | Zen, Chrome, Safari, Firefox, Arc, Obsidian |
| 2 code | Rex, Cursor, VS Code, Xcode, JetBrains IDEs, Claude, Codex, ChatGPT |
| 3 comms | WhatsApp, Zoom, Teams, Slack, Discord, Signal, Telegram, TeamSpeak, Messages, FaceTime, Fastmail, Outlook, Mail |
| 4 VMs | VMware Fusion, Parallels, UTM, VirtualBox (main screen; with two externals the widest) |

| Screens | Arrangement |
|---|---|
| MacBook alone, one regular monitor, or MacBook + one regular monitor | web on 1, code on 2 (`Hyper + Tab` flips between them); comms on the MacBook screen when it is open. Single-role workspaces stack (accordion) |
| An ultrawide (21:9 or wider: G9, 34") | web and code side by side on **2**: web 30% · code 40% · AI 30% on 32:9; web ⅓ · code + AI stacked ⅔ on 21:9. Workspace 1 stays empty |
| Two or more external monitors | web on one monitor, code on the widest, comms on the MacBook or a third monitor |

New windows of these apps go to their workspace by themselves (a Zoom or Teams meeting takes you to
3); plugging a screen in or out re-arranges after a few seconds. Terminals stay where you open them;
floating windows are left alone.

**Workspaces 4–10 are yours:** a window you move there (Zen next to the VM, say) stays until you
press `Hyper + Shift + A`. A new window opened next to one of the same role (Cmd+N in Zen on 4) stays
too. Only windows on 1–3 are re-sorted at login, on screen changes and with `Hyper + A`.

| Action | Keys |
|---|---|
| Re-sort workspaces 1–3 by role | `Hyper + A` |
| Re-sort everything, including what you moved to 4–10 | `Hyper + Shift + A` |

The app list lives in `~/.local/bin/aerospace-desk`; log in `~/Library/Logs/aerospace-desk.log`.

## Workspaces

| Action | Keys |
|---|---|
| Go to workspace 1–10 | `Hyper + 1` … `Hyper + 9`, `Hyper + 0` |
| Move window to workspace 1–10 | `Hyper + Shift + 1` … `9`, `0` |
| Back-and-forth (last workspace) | `Hyper + Tab` |
| Send workspace to next monitor | `Hyper + Shift + Tab` |

## macOS service mode (AeroSpace)

Enter with **`Hyper + Shift + ;`**, then:

| Key | Action |
|---|---|
| `Esc` | Reload config & exit mode |
| `R` | Reset layout (flatten tree) |
| `F` | Toggle floating / tiling |
| `Backspace` | Close all windows but current |
| `Hyper + Shift + H/J/K/L` | Join window with neighbour |

## Linux-only (Hyprland)

| Action | Keys |
|---|---|
| Quit Hyprland | `Hyper + Shift + E` |
| Lock (if hyprlock installed) | `Hyper + Esc` *(commented by default)* |
| Region screenshot (grim+slurp) | `Print` *(commented by default)* |

---

## Notes

- **Hyper = Ctrl+Alt+Cmd/Super on one thumb key.** It collides with nothing, so
  Cmd/Alt stay fully native for app shortcuts and terminal keys.
- Workspaces are numbered **1–10** on both machines for parity.
- AeroSpace has no true dwindle/spiral layout (uses `tiles` + `accordion`).
- Launcher tools: **Alfred** (macOS) / **walker** (Linux), both on the bare
  Cmd/Super key.

---

# Jump & find (zoxide · fzf)

| Action | Key / cmd |
|---|---|
| Jump to frecent dir | `z <query>` |
| Interactive dir jump | `zi` |
| Insert file path | `Ctrl + T` |
| `cd` into subdir | `Alt + C` |
| Fuzzy path completion | `<cmd> **<Tab>` |
| History search | `Ctrl + R` (fzf) |
| nvim (LazyVim) / learning config | `nvim` / `vik` |
