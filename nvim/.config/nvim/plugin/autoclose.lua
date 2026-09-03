-- Auto-pairs, hand-rolled.
--
-- Insert-mode expr maps only: no autocommands, no state, no plugin manager.
-- Every mapping returns the keys to type, so undo, dot-repeat and abbreviations
-- keep working the way they would if the keys had been typed by hand.

-- Bracket pairs: opener -> closer. These always come in twos, so the opener
-- and the closer get separate mappings.
local pairs_open = {
	["("] = ")",
	["["] = "]",
	["{"] = "}",
}

-- Quote pairs: the opener and the closer are the same character, so a single
-- mapping has to decide between opening, closing and inserting a bare quote.
local quotes = { '"', "'", "`" }

-- Quotes that mean something else in a given filetype, and so must never pair.
local quote_blocklist = {
	vim = { ['"'] = true }, -- comment leader
	rust = { ["'"] = true }, -- lifetimes
	lisp = { ["'"] = true }, -- quote form
	scheme = { ["'"] = true },
	clojure = { ["'"] = true },
	ocaml = { ["'"] = true }, -- type variables
	markdown = { ["'"] = true },
	text = { ["'"] = true },
	tex = { ["'"] = true, ["`"] = true },
}

-- A pair is only opened when the character to the right of the cursor is one
-- of these: end of line, whitespace, or something that closes/separates.
-- Typing "(" in front of a word is nearly always a wrap, not a new pair.
local function closes_before(char)
	return char == "" or char:match("[%s%)%]%}\"'`,;:%.]") ~= nil
end

local function context()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	return line:sub(col, col), line:sub(col + 1, col + 1)
end

-- <C-g>U keeps the current undo block intact across the cursor move, so a
-- pair plus its contents stays a single undoable edit.
--
-- These are returned as key notation, not raw bytes: an expr mapping with a
-- Lua rhs runs its result through replace_keycodes, which would escape raw
-- termcodes into literal text.
local left = "<C-g>U<Left>"
local right = "<C-g>U<Right>"

local function map(lhs, fn)
	vim.keymap.set("i", lhs, fn, { expr = true, silent = true, desc = "autoclose " .. lhs })
end

for open, close in pairs(pairs_open) do
	map(open, function()
		local _, after = context()
		if closes_before(after) then
			return open .. close .. left
		end
		return open
	end)

	map(close, function()
		local _, after = context()
		-- Step over the closer this mapping already inserted instead of
		-- stacking a second one.
		if after == close then
			return right
		end
		return close
	end)
end

for _, q in ipairs(quotes) do
	map(q, function()
		local blocked = quote_blocklist[vim.bo.filetype]
		if blocked and blocked[q] then
			return q
		end

		local before, after = context()

		if after == q then
			return right
		end
		-- An escaped quote is content, never a delimiter.
		if before == "\\" then
			return q
		end
		-- Adjacent to a word character on either side: an apostrophe, a digit
		-- suffix, or the tail of a string being edited.
		if before:match("[%w_]") or after:match("[%w_]") then
			return q
		end
		-- Third quote of """ or ''': the docstring case. Let it stand alone
		-- rather than opening a pair inside the one already there.
		if before == q then
			return q
		end
		if not closes_before(after) then
			return q
		end

		return q .. q .. left
	end)
end

-- <BS> between an empty pair removes both halves.
local function is_pair(before, after)
	if pairs_open[before] == after then
		return true
	end
	for _, q in ipairs(quotes) do
		if before == q and after == q then
			return true
		end
	end
	return false
end

map("<BS>", function()
	local before, after = context()
	if is_pair(before, after) then
		return "<BS><Del>"
	end
	return "<BS>"
end)

-- <CR> between an empty pair opens a properly indented block:
--
--   foo(|)   ->   foo(
--                     |
--                 )
--
-- <Esc>O re-runs the indent logic for the filetype instead of guessing at
-- shiftwidth here, which keeps cindent/indentexpr/lsp formatting authoritative.
map("<CR>", function()
	local before, after = context()
	if is_pair(before, after) and before ~= after then
		return "<CR><Esc>O"
	end
	return "<CR>"
end)
