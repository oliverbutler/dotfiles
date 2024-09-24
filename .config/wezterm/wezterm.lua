local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Theme
config.colors = require("cyberdream")
config.enable_tab_bar = false
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Fonts
-- Emojis 🤣💀👻✅🐳
--
config.font_size = 12.5
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.foreground_text_hsb = {
  hue = 1.0,
  saturation = 0.94, -- Was too saturated compared to iTerm as source of truth
  brightness = 1.0,
}
config.font = wezterm.font_with_fallback({
  {
    family = "JetBrains Mono",
    weight = "Regular",
  },
  { family = "Apple Color Emoji", assume_emoji_presentation = true, scale = 1.2 },
})

-- Window
config.window_background_opacity = 0.80
config.macos_window_background_blur = 100
config.adjust_window_size_when_changing_font_size = false
config.max_fps = 144
config.animation_fps = 60
config.cursor_blink_rate = 250

-- Fix opt+3 not giving # https://github.com/wez/wezterm/issues/4353#issuecomment-1759118679
config.send_composed_key_when_left_alt_is_pressed = true
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.initial_rows = 50
config.initial_cols = 180

return config
