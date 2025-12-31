local wezterm = require 'wezterm';
local act = wezterm.action
local config = {}

local is_windows = function()
  return wezterm.target_triple:find("windows") ~= nil
end

-- Get path separator based on OS
local function path_separator()
  return is_windows() and "\\" or "/"
end

-- Custom project switcher
local function project_switcher()
  local sep = path_separator()
  local search_paths = {}

  if is_windows() then
    search_paths = {
      wezterm.home_dir .. "\\dev",
      wezterm.home_dir .. "\\.dotfiles",
      [[C:\Sandboxes]]
    }
  else
    search_paths = {
      wezterm.home_dir .. "/dev",
      wezterm.home_dir .. "/.dotfiles",
    }
  end

  return act.InputSelector {
    title = "Select Project",
    choices = (function()
      local choices = {}

      for _, path in ipairs(search_paths) do
        local success, stdout, stderr

        if is_windows() then
          -- Use PowerShell to find git directories on Windows
          success, stdout, stderr = wezterm.run_child_process({
            "pwsh",
            "-NoProfile",
            "-Command",
            string.format(
              [[Get-ChildItem -Path "%s" -Directory -Recurse -Depth 2 -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq ".git" } | ForEach-Object { $_.Parent.FullName }]],
              path
            )
          })
        else
          -- Use find on Linux/Unix
          success, stdout, stderr = wezterm.run_child_process({
            "find",
            path,
            "-type", "d",
            "-name", ".git",
            "-maxdepth", "3"
          })
        end

        if success then
          for line in stdout:gmatch("[^\r\n]+") do
            local project_path = line

            -- On Unix, extract parent directory from .git path
            if not is_windows() then
              project_path = line:match("(.+)/.git$")
            end

            if project_path then
              -- Normalize path and create label
              project_path = project_path:gsub("[\r\n]", "")
              local label = project_path:gsub(wezterm.home_dir:gsub("\\", "\\\\"), "~")

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
        -- Extract project name from the path (works for both / and \)
        local project_name = id:match("([^/\\]+)$")

        -- Spawn a new tab with the selected directory
        window:perform_action(
          act.SpawnCommandInNewTab {
            cwd = id,
          },
          pane
        )

        -- Set the tab title to the project name after a brief delay
        if project_name then
          wezterm.time.call_after(0.1, function()
            local active_tab = window:active_tab()
            if active_tab then
              active_tab:set_title(project_name)
            end
          end)
        end
      end
    end),
  }
end

if is_windows() then
  config.default_prog = { 'pwsh' }
else
  config.default_prog = { 'bash' }
  config.enable_wayland = false
end
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold', italic = false })

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.adjust_window_size_when_changing_font_size = false
config.default_cursor_style = 'SteadyBar'

config.color_scheme = 'Gruvbox Dark (Gogh)'

-- Gruvbox colors with alpha channel for transparency support
local gruvbox = {
  bg = 'rgba(40, 40, 40, 1.0)',        -- #282828
  bg1 = 'rgba(60, 56, 54, 1.0)',       -- #3c3836
  fg = '#ebdbb2',
  green = '#b8bb26',
  gray = '#a89984',
  yellow = '#fabd2f',
}

config.colors = {
  tab_bar = {
    background = gruvbox.bg,
    active_tab = {
      bg_color = gruvbox.bg,
      fg_color = gruvbox.green,
    },
    inactive_tab = {
      bg_color = gruvbox.bg,
      fg_color = gruvbox.gray,
    },
    inactive_tab_hover = {
      bg_color = gruvbox.bg1,
      fg_color = gruvbox.fg,
    },
    new_tab = {
      bg_color = gruvbox.bg,
      fg_color = gruvbox.green,
    },
    new_tab_hover = {
      bg_color = gruvbox.bg1,
      fg_color = gruvbox.yellow,
    }
  }
}

config.front_end = 'OpenGL'

config.font_size = 13

config.window_decorations = 'RESIZE'

config.leader = { key = 'a', mods = 'CTRL' }

config.keys = {
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
    key = "Enter",
    mods = "SHIFT",
    action = act.SendString("\x1b\r"),
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
  {
    key = 'o',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      local overrides = window:get_config_overrides() or {}
      if overrides.window_background_opacity == 1.0 then
        local opacity = 0.5
        overrides.window_background_opacity = opacity
        overrides.colors = {
          tab_bar = {
            background = 'rgba(40, 40, 40, ' .. opacity .. ')',
            active_tab = {
              bg_color = 'rgba(40, 40, 40, ' .. opacity .. ')',
              fg_color = '#b8bb26',
            },
            inactive_tab = {
              bg_color = 'rgba(40, 40, 40, ' .. opacity .. ')',
              fg_color = '#a89984',
            },
            inactive_tab_hover = {
              bg_color = 'rgba(60, 56, 54, ' .. opacity .. ')',
              fg_color = '#ebdbb2',
            },
            new_tab = {
              bg_color = 'rgba(40, 40, 40, ' .. opacity .. ')',
              fg_color = '#b8bb26',
            },
            new_tab_hover = {
              bg_color = 'rgba(60, 56, 54, ' .. opacity .. ')',
              fg_color = '#fabd2f',
            }
          }
        }
      else
        overrides.window_background_opacity = 1.0
        overrides.colors = nil
      end
      window:set_config_overrides(overrides)
    end),
  },
}

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(wezterm.strftime('%a %b %d %H:%M:%S '))
end)

return config
