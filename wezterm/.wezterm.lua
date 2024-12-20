local wezterm = require 'wezterm';
local config = {}

local is_windows = function()
  return wezterm.target_triple:find("windows") ~= nil
end

if is_windows() then
  config.default_prog = { 'pwsh.exe' }
else
  config.default_prog = { 'zsh' }
end

config.enable_tab_bar = false
config.adjust_window_size_when_changing_font_size = false
config.default_cursor_style = 'SteadyBar'

config.color_scheme = 'Catppuccin Latte'

config.front_end = 'OpenGL'

config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold', italic = false })
config.font_size = 11.5

local opacity = 0.7

-- powershell opacity is annoying so if on windows just dont set the background opacity
if not is_windows() then
  config.window_background_opacity = opacity
end

config.window_decorations = 'RESIZE'

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
