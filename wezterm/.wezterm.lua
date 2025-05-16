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
config.font = wezterm.font('Monofur Nerd Font', { weight = 'Bold', italic = false })

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.adjust_window_size_when_changing_font_size = false
config.default_cursor_style = 'SteadyBar'

config.color_scheme = 'Catppuccin Macchiato'
config.colors = {
  tab_bar = {
    background = '#24273a',
    active_tab = {
      bg_color = '#24273a',
      fg_color = '#a6da95',
    },
    inactive_tab = {
      bg_color = '#24273a',
      fg_color = '#cad3f5',
    },
    new_tab = {
      bg_color = '#24273a',
      fg_color = '#a6da95',
    }
  }
}

config.front_end = 'OpenGL'

config.font_size = 11.5

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
