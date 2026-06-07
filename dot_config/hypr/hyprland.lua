-- Hyprland main config — Lua (Hyprland v0.55+)
-- Keybindings split into keybinds.lua, loaded via require() below.
-- Docs: https://wiki.hypr.land

-- ── Monitors ─────────────────────────────────────────────────────────────────
-- Default: every monitor at preferred resolution, auto-placed, scale auto.
-- Override per-display, e.g.: hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0 0", scale = 1 })
-- Inspect connected outputs with: hyprctl monitors
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- ── Environment ──────────────────────────────────────────────────────────────
-- Set via UWSM from ~/.config/uwsm/env and ~/.config/uwsm/env-hyprland.
-- Uncomment if running Hyprland without UWSM:
-- hl.env("XCURSOR_SIZE",    "24")
-- hl.env("HYPRCURSOR_SIZE", "24")

-- ── Autostart ────────────────────────────────────────────────────────────────
hl.on("hyprland.start", function()
    hl.exec_cmd("mako")                                         -- notification daemon
    hl.exec_cmd("hypridle")                                     -- idle management / lock screen trigger
    hl.exec_cmd("waybar")                                       -- status bar
    hl.exec_cmd("elephant")                                     -- walker companion daemon (app index)
    hl.exec_cmd("walker --gapplication-service")                -- walker background service
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- ── Look & feel ──────────────────────────────────────────────────────────────
hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 20,
        border_size      = 2,
        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- ── Dwindle layout ───────────────────────────────────────────────────────────
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- ── Input ────────────────────────────────────────────────────────────────────
hl.config({
    input = {
        -- ZSA boards (Moonlander/Voyager) emit US by default — change if your layer
        -- produces a different layout, or set kb_layout = "de" for a stock DE board.
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- ── Gestures ─────────────────────────────────────────────────────────────────
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- ── Animations ───────────────────────────────────────────────────────────────
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 }    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 }    } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 }       } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 }    } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 }     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default"       })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint"  })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy"          })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear"  })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear"  })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick"         })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint"  })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear"  })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear"  })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick"         })

-- ── Window rules ─────────────────────────────────────────────────────────────
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- ── Keybindings ──────────────────────────────────────────────────────────────
require("keybinds")
