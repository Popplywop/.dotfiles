local M = {}
local float_qf = require("float-qf")

--- Search upward from the current buffer's directory for files matching patterns.
--- Patterns are tried in priority order. For the first pattern that matches,
--- returns ALL matches in the same directory (to handle multiple sln/csproj files).
---@param patterns string[] Lua patterns to match filenames against
---@param buf? number Buffer handle (defaults to current buffer)
---@return string[] paths Absolute paths to matched files (may be empty)
local function find_root_files(patterns, buf)
  buf = buf or 0
  local bufpath = vim.api.nvim_buf_get_name(buf)
  if bufpath == "" then
    return {}
  end
  local start_dir = vim.fn.fnamemodify(bufpath, ":p:h")

  for _, pattern in ipairs(patterns) do
    -- First find one match to identify the directory
    local first = vim.fs.find(function(name)
      return name:match(pattern) ~= nil
    end, { path = start_dir, upward = true, type = "file", limit = 1 })
    if #first > 0 then
      local dir = vim.fn.fnamemodify(first[1], ":h")
      -- Now find all matches in that same directory (non-upward, no recursion)
      local all = vim.fs.find(function(name)
        return name:match(pattern) ~= nil
      end, { path = dir, type = "file", limit = 50 })
      -- Filter to only files directly in that directory (not subdirs)
      local results = {}
      for _, f in ipairs(all) do
        if vim.fn.fnamemodify(f, ":h") == dir then
          table.insert(results, f)
        end
      end
      if #results > 0 then
        return results
      end
    end
  end
  return {}
end

--- Resolve a list of found files to a single selection, prompting if multiple.
---@param files string[]
---@param label string Description for the prompt (e.g. "project")
---@param callback fun(path: string)
local function resolve_one(files, label, callback)
  if #files == 0 then
    return
  end
  if #files == 1 then
    callback(files[1])
    return
  end
  vim.ui.select(files, {
    prompt = "Select " .. label .. ":",
    format_item = function(path)
      return vim.fn.fnamemodify(path, ":t")
    end,
  }, function(choice)
    if choice then
      callback(choice)
    end
  end)
end

--- Find the project root file (slnx > sln > csproj) and pass it to callback.
--- Prompts with vim.ui.select if multiple matches exist.
---@param callback fun(path: string)
local function find_project_root(callback)
  local files = find_root_files({ "%.slnx$", "%.sln$", "%.csproj$" })
  if #files == 0 then
    vim.notify("No .slnx, .sln, or .csproj found", vim.log.levels.ERROR)
    return
  end
  resolve_one(files, "project", callback)
end

--- Find the nearest .csproj file and pass it to callback.
--- Prompts with vim.ui.select if multiple matches exist.
---@param callback fun(path: string)
local function find_nearest_csproj(callback)
  local files = find_root_files({ "%.csproj$" })
  if #files == 0 then
    vim.notify("No .csproj found", vim.log.levels.ERROR)
    return
  end
  resolve_one(files, ".csproj", callback)
end

--- Run a command asynchronously (hidden, output captured).
---@param cmd string[]
---@param opts { cwd?: string, on_done: fun(stdout: string[], stderr: string[], code: integer) }
local function run_async(cmd, opts)
  local stdout_lines = {}
  local stderr_lines = {}

  vim.fn.jobstart(cmd, {
    cwd = opts.cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stdout_lines, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stderr_lines, line)
          end
        end
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        opts.on_done(stdout_lines, stderr_lines, code)
      end)
    end,
  })
end

--- Run a command in a bottom split terminal with live output.
--- The terminal auto-scrolls and closes on q/Esc after the job finishes.
---@param cmd string Shell command string
---@param opts { cwd?: string, title?: string, on_exit?: fun(buf: integer, exit_code: integer) }
local function run_in_term(cmd, opts)
  opts = opts or {}
  local prev_win = vim.api.nvim_get_current_win()

  -- Open a bottom split, 15 rows tall
  vim.cmd("botright 15split")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, buf)
  vim.bo[buf].bufhidden = "wipe"

  if opts.title then
    vim.api.nvim_buf_set_name(buf, opts.title)
  end

  -- Run the command in the terminal buffer
  local shell_cmd = cmd
  if opts.cwd then
    shell_cmd = string.format("cd %s && %s", vim.fn.shellescape(opts.cwd), cmd)
  end

  vim.fn.termopen(shell_cmd, {
    on_exit = function(_, exit_code)
      vim.schedule(function()
        -- Check the buffer/window are still valid
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        -- Add close keymaps now that the job is done
        local kopts = { buffer = buf, silent = true }
        local function close()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
          if vim.api.nvim_win_is_valid(prev_win) then
            vim.api.nvim_set_current_win(prev_win)
          end
        end
        vim.keymap.set("n", "q", close, kopts)
        vim.keymap.set("n", "<Esc>", close, kopts)

        if opts.on_exit then
          opts.on_exit(buf, exit_code)
        end
      end)
    end,
  })

  -- Start in terminal mode so output streams visibly, then switch to normal
  -- mode when the user presses Esc (terminal mode Esc is handled by termopen)
  vim.cmd("startinsert")
end

--- Parse MSBuild output lines into quickfix entries.
---@param lines string[]
---@return table[] qf_entries
local function parse_msbuild(lines)
  local entries = {}
  for _, line in ipairs(lines) do
    local file, lnum, col, severity, code, msg =
      line:match("^%s*(.-)%((%d+),(%d+)%): (%w+) (%w+): (.+)$")
    if file and lnum then
      local qf_type = "W"
      if severity:lower() == "error" then
        qf_type = "E"
      end
      table.insert(entries, {
        filename = file,
        lnum = tonumber(lnum),
        col = tonumber(col),
        text = code .. ": " .. msg,
        type = qf_type,
      })
    end
  end
  return entries
end

--- Build the project/solution.
function M.build()
  find_project_root(function(root)
    local root_dir = vim.fn.fnamemodify(root, ":h")
    local root_name = vim.fn.fnamemodify(root, ":t")

    run_in_term("dotnet build " .. vim.fn.shellescape(root), {
      cwd = root_dir,
      title = "dotnet build " .. root_name,
      on_exit = function(buf, exit_code)
        -- Parse terminal buffer lines for diagnostics
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local entries = parse_msbuild(lines)

        if #entries > 0 then
          vim.fn.setqflist(entries)
          vim.notify(
            string.format("Build finished with %d diagnostic(s) — :copen to view", #entries),
            vim.log.levels.WARN
          )
        elseif exit_code == 0 then
          vim.fn.setqflist({})
        end
      end,
    })
  end)
end

--- Restore packages for the project/solution.
function M.restore()
  find_project_root(function(root)
    local root_dir = vim.fn.fnamemodify(root, ":h")
    local root_name = vim.fn.fnamemodify(root, ":t")

    run_in_term("dotnet restore " .. vim.fn.shellescape(root), {
      cwd = root_dir,
      title = "dotnet restore " .. root_name,
    })
  end)
end

--- Add a NuGet package to the nearest .csproj.
---@param name? string Package name; prompts if nil
function M.package_add(name)
  find_nearest_csproj(function(csproj)
    local function do_add(pkg_name)
      if not pkg_name or pkg_name == "" then
        return
      end
      local csproj_dir = vim.fn.fnamemodify(csproj, ":h")
      vim.notify("Adding package " .. pkg_name .. "...", vim.log.levels.INFO)

      run_async({ "dotnet", "add", csproj, "package", pkg_name }, {
        cwd = csproj_dir,
        on_done = function(_, _, code)
          if code == 0 then
            vim.notify("Added " .. pkg_name, vim.log.levels.INFO)
          else
            vim.notify("Failed to add " .. pkg_name .. " (exit " .. code .. ")", vim.log.levels.ERROR)
          end
        end,
      })
    end

    if name then
      do_add(name)
    else
      vim.ui.input({ prompt = "Package name: " }, do_add)
    end
  end)
end

--- Find all .csproj files under the project root directory.
---@return string[] paths
local function find_all_csproj()
  local root_files = find_root_files({ "%.slnx$", "%.sln$", "%.csproj$" })
  if #root_files == 0 then
    return {}
  end
  -- Use the directory of the root file as the workspace root
  local root_dir = vim.fn.fnamemodify(root_files[1], ":h")
  return vim.fs.find(function(name)
    return name:match("%.csproj$") ~= nil
  end, { path = root_dir, type = "file", limit = 100 })
end

--- Add a project reference. Prompts user to select target project and source reference.
function M.reference_add()
  local all = find_all_csproj()
  if #all < 2 then
    vim.notify("Need at least 2 .csproj files to add a reference", vim.log.levels.ERROR)
    return
  end

  vim.ui.select(all, {
    prompt = "Target project (add reference TO):",
    format_item = function(path)
      return vim.fn.fnamemodify(path, ":t")
    end,
  }, function(target)
    if not target then
      return
    end

    -- Filter out the target from the reference choices
    local refs = {}
    for _, f in ipairs(all) do
      if f ~= target then
        table.insert(refs, f)
      end
    end

    vim.ui.select(refs, {
      prompt = "Reference project (add reference FROM):",
      format_item = function(path)
        return vim.fn.fnamemodify(path, ":t")
      end,
    }, function(source)
      if not source then
        return
      end

      local target_dir = vim.fn.fnamemodify(target, ":h")
      vim.notify(
        "Adding reference " .. vim.fn.fnamemodify(source, ":t") .. " → " .. vim.fn.fnamemodify(target, ":t") .. "...",
        vim.log.levels.INFO
      )

      run_async({ "dotnet", "add", target, "reference", source }, {
        cwd = target_dir,
        on_done = function(_, _, code)
          if code == 0 then
            vim.notify("Added reference " .. vim.fn.fnamemodify(source, ":t"), vim.log.levels.INFO)
          else
            vim.notify("Failed to add reference (exit " .. code .. ")", vim.log.levels.ERROR)
          end
        end,
      })
    end)
  end)
end

--- Search NuGet for packages and show results in a floating list.
--- Selecting a result calls package_add with that package ID.
---@param query? string Search query; prompts if nil
function M.package_search(query)
  local function do_search(q)
    if not q or q == "" then
      return
    end
    vim.notify("Searching NuGet for '" .. q .. "'...", vim.log.levels.INFO)

    run_async({ "dotnet", "package", "search", q, "--format", "json" }, {
      on_done = function(stdout, _, code)
        if code ~= 0 then
          vim.notify("Package search failed (exit " .. code .. ")", vim.log.levels.ERROR)
          return
        end

        local json_str = table.concat(stdout, "\n")
        local ok, parsed = pcall(vim.json.decode, json_str)
        if not ok or not parsed then
          vim.notify("Failed to parse search results", vim.log.levels.ERROR)
          return
        end

        local items = {}
        local results = parsed.searchResult or {}
        for _, source in ipairs(results) do
          for _, pkg in ipairs(source.packages or {}) do
            local downloads = pkg.totalDownloads or 0
            local display = string.format(
              "%-42s v%-14s %s downloads",
              pkg.id or "",
              pkg.latestVersion or "",
              tostring(downloads)
            )
            table.insert(items, { display = display, data = pkg })
          end
        end

        if #items == 0 then
          vim.notify("No packages found for '" .. q .. "'", vim.log.levels.INFO)
          return
        end

        float_qf.open_float_list(items, {
          title = "NuGet: " .. q,
          on_select = function(item)
            M.package_add(item.data.id)
          end,
        })
      end,
    })
  end

  if query then
    do_search(query)
  else
    vim.ui.input({ prompt = "NuGet search: " }, do_search)
  end
end

return M
