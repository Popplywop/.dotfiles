local wezterm = require 'wezterm';
local config = {}

config.default_prog = { 'zsh' }
config.enable_tab_bar = false
config.adjust_window_size_when_changing_font_size = false
config.default_cursor_style = 'SteadyBar'

config.color_scheme = 'Catppuccin Latte'

config.front_end = 'OpenGL'

config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold', italic = false })
config.font_size = 11.5

local opacity = 0.7
config.window_background_opacity = opacity

wezterm.on("toggle-opacity", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 1.0
  else
    overrides.window_background_opacity = nil
  end
  window:set_config_overrides(overrides)
end)

config.leader = { key = 'a', mods = 'CTRL' }

config.keys = {
  {
    key = 'w',
    mods = 'LEADER',
    action = wezterm.action.CloseCurrentTab { confirm = true }
  },
  {
    key = "O",
    mods = "CTRL",
    action = wezterm.action.EmitEvent("toggle-opacity"),
  }
}

return config
