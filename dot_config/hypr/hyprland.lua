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
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- ── Autostart ────────────────────────────────────────────────────────────────
hl.on("hyprland.start", function()
    hl.exec_cmd("walker --gapplication-service")        -- background service → instant startup
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- hl.exec_cmd("waybar")
end)

-- ── Look & feel ──────────────────────────────────────────────────────────────
hl.config({
    general = {
        gaps_in          = 8,
        gaps_out         = 8,
        border_size      = 2,
        col = {
            active_border   = { colors = { "rgba(89b4faee)", "rgba(74c7ecee)" }, angle = 45 },
            inactive_border = "rgba(313244aa)",
        },
        layout           = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding = 8,
        blur = {
            enabled = true,
            size    = 4,
            passes  = 2,
        },
        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
        },
    },

    -- dwindle: Hyprland's spiral/BSP layout (closest analogue to AeroSpace tiles).
    dwindle = {
        pseudotile     = true,
        preserve_split = true,
    },

    input = {
        -- ZSA boards (Moonlander/Voyager) emit US by default — change if your layer
        -- produces a different layout, or set kb_layout = "de" for a stock DE board.
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
        },
    },

    gestures = {
        workspace_swipe = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },
})

-- ── Animations ───────────────────────────────────────────────────────────────
hl.curve("ease", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "ease" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "ease", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "ease" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "ease", style = "slide" })

-- ── Keybindings ──────────────────────────────────────────────────────────────
require("keybinds")
