local wezterm = require 'wezterm';
local act = wezterm.action
local config = {}

local is_windows = function()
  return wezterm.target_triple:find("windows") ~= nil
end

if is_windows() then
  config.default_prog = { 'pwsh.exe' }
else
  config.default_prog = { 'bash' }
  config.enable_wayland = false
end

config.enable_tab_bar = true
config.tab_bar_at_bottom = true

config.adjust_window_size_when_changing_font_size = false
config.default_cursor_style = 'SteadyBar'

config.color_scheme = 'Catppuccin Mocha'

config.front_end = 'OpenGL'

config.font_size = 11.5

local opacity = 0.7

config.window_decorations = 'RESIZE'

config.leader = { key = 'a', mods = 'CTRL' }

config.keys = {
  {
    key = 'w',
    mods = 'LEADER',
    action = act.CloseCurrentTab { confirm = true }
  },
  {
    key = 'E',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }
  },
  {
    key = "r",
    mods = "LEADER",
    action = act.ReloadConfiguration
  },
}

return config
