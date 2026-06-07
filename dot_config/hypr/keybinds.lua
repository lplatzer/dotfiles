-- Hyprland keybinds — the Linux half of a cross-platform tiling setup.
-- Mirrors ~/.aerospace.toml on macOS. Loaded via require("keybinds") from hyprland.lua.
--
-- Unified mod key: ALT (same physical key + behaviour as AeroSpace on macOS).
-- Launcher lives on SUPER+Space (mirroring Alfred on Cmd+Space) — deliberately a
-- different modifier from mod so a custom keyboard remap of Cmd/Super+Space
-- stays correct across both machines.

local mod = "ALT"

-- ── Apps ─────────────────────────────────────────────────────────────────────
hl.bind(mod .. " + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + Space",    hl.dsp.exec_cmd("walker"))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd("nautilus"))

-- ── Window operations (mirror AeroSpace) ─────────────────────────────────────
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + comma", hl.dsp.window.pseudo())
hl.bind(mod .. " + slash", hl.dsp.layout("togglesplit"))

-- ── Focus (vim h/j/k/l) ──────────────────────────────────────────────────────
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))

-- ── Move window ──────────────────────────────────────────────────────────────
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- ── Resize (repeating) ───────────────────────────────────────────────────────
hl.bind(mod .. " + minus", hl.dsp.window.resize({ x = -50, y = 0 }), { repeating = true })
hl.bind(mod .. " + equal", hl.dsp.window.resize({ x = 50, y = 0 }), { repeating = true })

-- ── Workspaces 1–10 ──────────────────────────────────────────────────────────
for i = 1, 9 do
	hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- ── Workspace navigation ─────────────────────────────────────────────────────
hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.workspace.move({ monitor = "+1" }))

-- ── Mouse (drag to move/resize) ──────────────────────────────────────────────
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Hyprland-specific (no AeroSpace equivalent) ──────────────────────────────
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))

-- ── Screenshots (grim + slurp + satty) ──────────────────────────────────────
hl.bind("Print",           hl.dsp.exec_cmd([[grim -g "$(slurp)" - | satty --filename -]]))
hl.bind("SHIFT + Print",   hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))

-- ── Media keys (pipewire-pulse + wireplumber) ────────────────────────────────
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

-- ── Brightness (brightnessctl) ───────────────────────────────────────────────
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
