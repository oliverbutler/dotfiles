local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.9
config.macos_window_background_blur = 15
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Fonts
config.font_size = 12.0
config.font = wezterm.font_with_fallback({
  {
    family = "JetBrains Mono",
    weight = "DemiBold",
  },
  { family = "Apple Color Emoji", assume_emoji_presentation = true },
})

config.adjust_window_size_when_changing_font_size = false

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.initial_rows = 50
config.initial_cols = 180

return config
