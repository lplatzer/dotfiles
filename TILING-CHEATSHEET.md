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
| New terminal (Ghostty) | `Hyper + Enter` |
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
| Shrink / grow | `Hyper + -` / `Hyper + =` |
| Drag to move / resize | hold `Hyper` + left / right mouse |

## Layout

| Action | macOS (AeroSpace) | Linux (Hyprland) |
|---|---|---|
| Toggle split orientation | `Hyper + /` | `Hyper + /` (togglesplit) |
| Accordion / pseudotile | `Hyper + ,` | `Hyper + ,` (pseudo) |

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
  Cmd/Alt stay fully native for app shortcuts and terminal/zellij keys.
- Workspaces are numbered **1–10** on both machines for parity.
- AeroSpace has no true dwindle/spiral layout (uses `tiles` + `accordion`).
- Launcher tools: **Alfred** (macOS) / **walker** (Linux), both on the bare
  Cmd/Super key.

---

# Terminal multiplexing — zellij

Layering: **AeroSpace/Hyprland** tile *windows*, **zellij** multiplexes panes/tabs
*inside one Ghostty window*. Auto-attaches on every new Ghostty. Raw shell (no
zellij): `ZELLIJ_AUTO_ATTACH=false zsh`.

Because the WM mod is now **Hyper**, `Alt` is free — zellij's quick keys all work:

| Quick key (no mode) | Action |
|---|---|
| `Alt + N` | new pane |
| `Alt + ←↑↓→` (or `Alt + H/J/K/L`) | focus pane |
| `Alt + =` / `Alt + -` | grow / shrink |
| `Alt + F` | toggle floating pane |
| `Alt + [` / `Alt + ]` | prev / next layout |
| `Alt + I` / `Alt + O` | move tab left / right |

Mode system — press the `Ctrl` combo, then the key; `Enter`/`Esc` exits:

| Mode | Enter | Then |
|---|---|---|
| Pane | `Ctrl + P` | `n` new · `d`/`r` split down/right · `x` close · `f` fullscreen · `w` float · `h/j/k/l` focus |
| Tab | `Ctrl + T` | `n` new · `x` close · `1–9` goto · `h/l` prev/next · `r` rename · `b` break pane→tab |
| Resize | `Ctrl + N` | `h/j/k/l` or `+`/`-` |
| Scroll | `Ctrl + S` | `↑/↓` scroll · `s` search · `e` edit scrollback in `$EDITOR` |
| Session | `Ctrl + O` | `w` session-manager · `d` detach · `c` config |
| Move | `Ctrl + H` | `h/j/k/l` move pane |
| Lock / Quit | `Ctrl + G` / `Ctrl + Q` | lock all keys / quit zellij |

Sessions: `zellij ls` list · `zellij a <name>` attach · `Ctrl+O`→`d` detach ·
`zellij --layout dev` start a layout. Sessions serialize (resume via `Ctrl+O`→`w`).

# Project sessionizer (fzf + zoxide)

| Action | Key / cmd |
|---|---|
| Pick a project → its zellij session | **`Ctrl + F`** (or run `sessionizer`) |
| Candidates | both nvim configs + `~/projects/**` |
| Per-project layout | auto-applies if `~/.config/zellij/layouts/<name>.kdl` exists |
| **leitwerk** | opens `nvim` + `compose` tabs |

Add a project layout: drop `~/.config/zellij/layouts/<projectname>.kdl`.

# Jump & find (zoxide · fzf · atuin)

| Action | Key / cmd |
|---|---|
| Jump to frecent dir | `z <query>` |
| Interactive dir jump | `zi` |
| Insert file path | `Ctrl + T` |
| `cd` into subdir | `Alt + C` |
| Fuzzy path completion | `<cmd> **<Tab>` |
| History search | `Ctrl + R` (atuin) |
| nvim (LazyVim) / kickstart | `nvim` / `vik` |
