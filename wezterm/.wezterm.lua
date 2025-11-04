local wezterm = require 'wezterm';
local act = wezterm.action
local config = {}

-- Custom project switcher
local function project_switcher()
  local search_paths = {
    wezterm.home_dir .. "/dev",
    wezterm.home_dir .. "/.dotfiles",
  }

  return act.InputSelector {
    title = "Select Project",
    choices = (function()
      local choices = {}
      for _, path in ipairs(search_paths) do
        -- Find git directories
        local success, stdout = wezterm.run_child_process({
          "find",
          path,
          "-type", "d",
          "-name", ".git",
          "-maxdepth", "3"
        })

        if success then
          for line in stdout:gmatch("[^\r\n]+") do
            -- Get parent directory of .git folder
            local project_path = line:match("(.+)/.git$")
            if project_path then
              local label = project_path:gsub(wezterm.home_dir, "~")
              table.insert(choices, {
                label = label,
                id = project_path,
              })
            end
          end
        end
      end

      -- Sort choices alphabetically
      table.sort(choices, function(a, b)
        return a.label < b.label
      end)

      return choices
    end)(),

    action = wezterm.action_callback(function(window, pane, id, label)
      if id then
        -- Spawn a new tab with the selected directory
        window:perform_action(
          act.SpawnCommandInNewTab {
            cwd = id,
          },
          pane
        )
      end
    end),
  }
end

local is_windows = function()
  return wezterm.target_triple:find("windows") ~= nil
end

config.wsl_domains = {
  {
    name = 'WSL:Ubuntu',
    distribution = 'Ubuntu'
  }
}

if is_windows() then
  config.default_domain = 'WSL:Ubuntu'
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

config.color_scheme = 'Campbell (Gogh)'

config.colors = {
  tab_bar = {
    background = '#0C0C0C',
    active_tab = {
      bg_color = '#0C0C0C',
      fg_color = '#a6da95',
    },
    inactive_tab = {
      bg_color = '#0C0C0C',
      fg_color = '#cad3f5',
    },
    new_tab = {
      bg_color = '#0C0C0C',
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
    mods = "CTRL|SHIFT",
    action = act.ReloadConfiguration
  },
  {
    key = 's',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(project_switcher(), pane)
    end),
  },
}

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(wezterm.strftime('%a %b %d %H:%M:%S '))
end)

return config
