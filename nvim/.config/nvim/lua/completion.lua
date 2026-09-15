-- Autocompletion, native and plugin-free. Two halves:
--
-- Insert mode: 'autocomplete' opens the popup menu as you type and fills it
-- from the sources listed in 'complete' -- the current buffer, other
-- buffers, the LSP (through 'omnifunc', which vim.lsp sets per buffer on
-- attach) and filesystem paths (the F source below). Sources earlier in
-- 'complete' get a larger slice of the decaying timeout, so the LSP sits
-- near the front.
--
-- Command line: wildtrigger() on every keystroke turns 'wildmenu' into a
-- popup that updates as you type, which covers Ex command names, their
-- arguments and paths -- including the fuzzy 'findfunc' in lua/find.lua.

-- Filesystem source for 'complete'. Only answers once the text under the
-- cursor looks like a path, so ordinary words are left to the other sources.
local function looks_like_path(text)
	return text:find("/", 1, true) ~= nil or text:sub(1, 1) == "~"
end

function _G.path_complete(findstart, base)
	local line = vim.api.nvim_get_current_line()
	local col = vim.fn.col(".") - 1

	if findstart == 1 then
		local start = col
		while start > 0 and line:sub(start, start):match("[%w%._%-~/@%+%$]") do
			start = start - 1
		end
		return start
	end

	if not looks_like_path(base) then
		return {}
	end

	local items = {}
	for _, path in ipairs(vim.fn.getcompletion(base, "file")) do
		items[#items + 1] = {
			word = path,
			kind = path:sub(-1) == "/" and "Folder" or "File",
		}
		if #items >= 100 then
			break
		end
	end
	-- "always" re-runs the function as the path grows, so descending into a
	-- directory lists that directory instead of reusing the parent's matches.
	return { words = items, refresh = "always" }
end

vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.complete = ".^10,o,Fv:lua.path_complete,w^5,b^5"
vim.o.autocomplete = true
-- Small delay so the popup follows typing rather than racing it.
vim.o.autocompletedelay = 60

-- <Tab>/<S-Tab> walk the popup when it is open and are literal otherwise.
-- <C-y> accepts, which is also what applies LSP side effects (snippets,
-- auto-imports).
vim.keymap.set("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
vim.keymap.set("i", "<S-Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

vim.o.wildmode = "noselect:lastused,full"
vim.o.wildoptions = "pum,tagfile"

local cmdline_completion = vim.api.nvim_create_augroup("cmdline_completion", { clear = true })

vim.api.nvim_create_autocmd("CmdlineChanged", {
	group = cmdline_completion,
	pattern = { ":", "/", "?" },
	callback = function()
		vim.fn.wildtrigger()
	end,
})

-- Nothing is selected by default, so leaving `:find ` would otherwise run
-- with the raw fuzzy pattern instead of a file. Commit the first match.
vim.api.nvim_create_autocmd("CmdlineLeavePre", {
	group = cmdline_completion,
	pattern = ":",
	callback = function()
		local info = vim.fn.cmdcomplete_info()
		local matches = info.matches or {}
		if #matches > 0 and info.selected == -1 and vim.fn.getcmdline():match("^%s*fin[d]?%s") then
			vim.fn.setcmdline("find " .. matches[1])
		end
	end,
})

-- Keep <Up>/<Down> on command-line history rather than the popup.
vim.keymap.set("c", "<Up>", function()
	return vim.fn.wildmenumode() == 1 and "<C-e><Up>" or "<Up>"
end, { expr = true })
vim.keymap.set("c", "<Down>", function()
	return vim.fn.wildmenumode() == 1 and "<C-e><Down>" or "<Down>"
end, { expr = true })
