local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Theme
config.color_scheme = "catppuccin-mocha"
config.enable_tab_bar = false
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Fonts
-- Emojis 🤣💀👻✅🐳
config.font_size = 12.0
config.foreground_text_hsb = {
  hue = 1.0,
  saturation = 0.95,
  brightness = 1.0,
}
config.font = wezterm.font_with_fallback({
  {
    family = "JetBrains Mono",
  },
  { family = "Apple Color Emoji", assume_emoji_presentation = true, scale = 1.2 },
})

-- Window
config.window_background_opacity = 0.9
config.macos_window_background_blur = 15
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
