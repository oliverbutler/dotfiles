local wezterm = require("wezterm")

local config = wezterm.config_builder()
--
-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "catppuccin-mocha"
	else
		return "catppuccin-latte"
	end
end

-- Theme
config.color_scheme = scheme_for_appearance(get_appearance())
config.enable_tab_bar = false
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Fonts
-- Emojis 🤣💀👻✅🐳
--
config.font_size = 13.0
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.font = wezterm.font_with_fallback({
	{
		family = "JetBrains Mono",
		weight = "Regular",
	},
	{ family = "Apple Color Emoji", assume_emoji_presentation = true, scale = 1.2 },
})

-- Window
config.window_background_opacity = 0.96
config.macos_window_background_blur = 50
config.adjust_window_size_when_changing_font_size = false
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
