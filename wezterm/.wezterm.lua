local wezterm = require 'wezterm';
local act = wezterm.action
local config = {}

local is_windows = function()
  return wezterm.target_triple:find("windows") ~= nil
end

if is_windows() then
  config.default_prog = { 'pwsh.exe' }
else
  config.default_prog = { 'zsh' }
end

config.enable_tab_bar = true
config.tab_bar_at_bottom = true

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
    action = act.CloseCurrentTab { confirm = true }
  },
  {
    key = "O",
    mods = "CTRL",
    action = act.EmitEvent("toggle-opacity"),
  },
  {
    key = 'E',
    mods = 'CTRL|SHIFT',
    action = act.PromptInput {
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }
  }
}

return config
