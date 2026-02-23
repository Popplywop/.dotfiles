local M = {}

-- Create a floating quickfix window
local function open_float_qf()
  local qf_list = vim.fn.getqflist()
  if #qf_list == 0 then
    vim.notify("Quickfix list is empty", vim.log.levels.INFO)
    return
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Quickfix ",
    title_pos = "center",
  })

  -- Format quickfix entries for display
  local lines = {}
  for i, item in ipairs(qf_list) do
    local fname = item.bufnr > 0 and vim.fn.bufname(item.bufnr) or item.filename or ""
    local lnum = item.lnum or 0
    local col_nr = item.col or 0
    local text = item.text or ""
    table.insert(lines, string.format("%d. %s:%d:%d: %s", i, fname, lnum, col_nr, text))
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  -- Keymaps for the floating window
  local opts = { buffer = buf, silent = true }

  -- Close window
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, opts)
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, opts)

  -- Jump to quickfix entry
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    vim.api.nvim_win_close(win, true)
    vim.cmd("cc " .. line)
  end, opts)

  -- Navigate entries
  vim.keymap.set("n", "j", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    if line < #qf_list then
      vim.api.nvim_win_set_cursor(win, { line + 1, 0 })
    end
  end, opts)
  vim.keymap.set("n", "k", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    if line > 1 then
      vim.api.nvim_win_set_cursor(win, { line - 1, 0 })
    end
  end, opts)
end

-- Run eslint on changed files and populate quickfix
local function eslint_changed_files()
  -- Get git root from current buffer's directory
  local buf_dir = vim.fn.expand("%:p:h")
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(buf_dir) .. " rev-parse --show-toplevel")[1]

  if vim.v.shell_error ~= 0 or not git_root then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end

  vim.notify("Running eslint on changed files in " .. git_root, vim.log.levels.INFO)

  local cmd = "git diff --name-only --diff-filter=ACMR develop | grep -E '\\.(ts|js)$' | xargs -r pnpm exec eslint --fix --no-warn-ignored -f unix"

  local output_lines = {}

  vim.fn.jobstart(cmd, {
    cwd = git_root,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line and line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      -- ESLint outputs lint results to stdout, but capture stderr too just in case
      if data then
        for _, line in ipairs(data) do
          if line and line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_exit = function(_)
        local qf_entries = {}
        for _, line in ipairs(output_lines) do
          -- Parse unix format: file:line:col: message
          local file, lnum, col_nr, msg = line:match("^(.+):(%d+):(%d+): (.+)$")
          if file and lnum then
            table.insert(qf_entries, {
              filename = file,
              lnum = tonumber(lnum),
              col = tonumber(col_nr),
              text = msg,
            })
          end
        end

        if #qf_entries > 0 then
          vim.fn.setqflist(qf_entries)
          vim.notify(string.format("Found %d eslint issues", #qf_entries), vim.log.levels.WARN)
          open_float_qf()
        else
          vim.fn.setqflist({})
          vim.notify("No eslint issues found (or no changed files).", vim.log.levels.INFO)
        end
    end,
  })
end

-- Open a floating list with custom items and on_select callback
local function open_float_list(items, opts)
  opts = opts or {}
  if #items == 0 then
    vim.notify("No items to display", vim.log.levels.INFO)
    return
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col_pos = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)

  local title = opts.title and (" " .. opts.title .. " ") or " List "
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col_pos,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })

  local lines = {}
  for _, item in ipairs(items) do
    table.insert(lines, item.display)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local kopts = { buffer = buf, silent = true }

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, kopts)
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, kopts)

  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    local selected = items[line]
    vim.api.nvim_win_close(win, true)
    if opts.on_select and selected then
      opts.on_select(selected)
    end
  end, kopts)

  vim.keymap.set("n", "j", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    if line < #items then
      vim.api.nvim_win_set_cursor(win, { line + 1, 0 })
    end
  end, kopts)
  vim.keymap.set("n", "k", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    if line > 1 then
      vim.api.nvim_win_set_cursor(win, { line - 1, 0 })
    end
  end, kopts)
end

M.open_float_qf = open_float_qf
M.open_float_list = open_float_list
M.eslint_changed_files = eslint_changed_files

return M
