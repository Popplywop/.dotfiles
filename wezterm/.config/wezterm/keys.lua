local wezterm = require 'wezterm'
local utils = require 'utils'

local module = {}

function module.apply_to_config(config)
  config.leader = { key = 'z', mods = 'CTRL' }
  config.keys = {
    {
      key = 's',
      mods = 'CTRL|SHIFT',
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(utils.project_switcher(), pane)
      end),
    },
    {
      key = 'v',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.PasteFrom 'Clipboard',
    },
    {
      key = 'Insert',
      mods = 'SHIFT',
      action = wezterm.action.PasteFrom 'Clipboard',
    },
    {
      key = 'c',
      mods = 'LEADER',
      action = wezterm.action.SpawnTab 'CurrentPaneDomain',
    },
    {
      key = 'n',
      mods = 'LEADER',
      action = wezterm.action.ActivateTabRelative(1),
    },
    {
      key = 'p',
      mods = 'LEADER',
      action = wezterm.action.ActivateTabRelative(-1),
    },
    {
      key = 'w',
      mods = 'LEADER',
      action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' },
    },
    {
      key = 'a',
      mods = 'LEADER',
      action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|DOMAINS' },
    },
    {
      key = 'd',
      mods = 'LEADER',
      action = wezterm.action.DetachDomain 'CurrentPaneDomain',
    },
    {
      key = ',',
      mods = 'LEADER',
      action = wezterm.action.PromptInputLine {
        description = 'Rename tab',
        action = wezterm.action_callback(function(window, pane, line)
          if line and #line > 0 then
            window:active_tab():set_title(line)
          end
        end),
      },
    },
  }
end

return module
