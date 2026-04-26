local wezterm = require 'wezterm'
local module = {}

function module.project_switcher()
  local search_paths = {}
  local home_for_label = wezterm.home_dir

  search_paths = {
    wezterm.home_dir,
    wezterm.home_dir .. "/dev",
    wezterm.home_dir .. "/.dotfiles",
  }

  return wezterm.action.InputSelector {
    title = "Select Project",
    choices = (function()
      local choices = {}
      local seen_projects = {}

      for _, path in ipairs(search_paths) do
        local success, stdout, stderr

        -- Use find on Linux/Unix
        success, stdout, stderr = wezterm.run_child_process({
          "fd", "-a", "-t", "d", "-d", "3", "-H", "-g", ".git", path,
        })

        if success then
          for line in stdout:gmatch("[^\r\n]+") do
            line = line:gsub("/+$", "")

            -- Extract parent directory from the .git path returned by fd
            local project_path = line:match("(.+)/%.git$")

            if project_path then
              project_path = project_path:gsub("[\r\n]", "")
              if not seen_projects[project_path] then
                seen_projects[project_path] = true

                local label = project_path:gsub(home_for_label, "~")

                table.insert(choices, {
                  label = label,
                  id = project_path,
                })
              end
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
        -- Extract project name from the path
        local project_name = id:match("([^/]+)$")

        -- Spawn a new tab with the selected directory
        local spawn_opts = { cwd = id }

        window:perform_action(
          wezterm.action.SpawnCommandInNewTab(spawn_opts),
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

return module
