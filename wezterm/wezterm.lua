-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {
  force_reverse_video_cursor = true,
  colors = {
    foreground = "#dcd7ba",
    background = "#181616",

    cursor_bg = "#c8c093",
    cursor_fg = "#c8c093",
    cursor_border = "#c8c093",

    selection_fg = "#c8c093",
    selection_bg = "#2d4f67",

    scrollbar_thumb = "#16161d",
    split = "#16161d",

    ansi = { "#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
    brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
    indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
  },
}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
config.window_padding = {
  top = 0,
  right = 0,
  left = 0,
}
config.force_reverse_video_cursor = true
config.colors = {}
config.colors.foreground = "#dcd7ba"
config.colors.background = "#181616"
config.colors.cursor_bg = "#c8c093"
config.colors.cursor_fg = "#c8c093"
config.colors.cursor_border = "#c8c093"
config.colors.selection_fg = "#c8c093"
config.colors.selection_bg = "#2d4f67"
config.colors.scrollbar_thumb = "#16161d"
config.colors.split = "#16161d"
config.colors.ansi = { "#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" }
config.colors.brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" }
config.colors.indexed = { [16] = "#ffa066", [17] = "#ff5d62" }
--  change
config.window_background_opacity = 0.95
config.window_decorations = "NONE"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 19
config.line_height = 1.0
config.cursor_blink_interval = 0.5
config.cursor_shape = "block"
config.cursor_style = "bar"
config.cursor_trail = "underline"
config.cursor_width = 2
config.cursor_animation_style = "blinking-underline"
config.cursor_animation_speed = 500
config.selection_animation_style = "blinking-underline"
config.selection_animation_speed = 500
config.enable_24_bit_color = true
config.enable_clipboard_notice = true
config.dynamic_title = true
config.tab_bar_style = "hidden"
config.hide_tab_bar_if_only_one_tab = true
config.enable_tab_bar = false

-- activate ONLY if windows --

-- config.default_domain = 'WSL:Ubuntu'
-- config.front_end = "OpenGL"

-- and finally, return the configuration to wezterm
return config
