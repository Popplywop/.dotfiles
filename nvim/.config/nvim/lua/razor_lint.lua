-- Tag-balance diagnostics for razor/cshtml buffers. vscode-html-language-server
-- publishes no diagnostics and the syntax file only colours, so this is a small
-- scanner that reports unclosed, stray and mismatched tags.
local ns = vim.api.nvim_create_namespace("razor_lint")

local void = {}
for t in ("area base br col embed hr img input link meta param source track wbr"):gmatch("%S+") do
	void[t] = true
end
-- End tag may be omitted in HTML; never report these as unclosed.
local optional_end = {}
for t in ("li p td th tr dt dd option thead tbody tfoot colgroup optgroup"):gmatch("%S+") do
	optional_end[t] = true
end
local raw_text = { script = true, style = true }

-- Find the `>` ending a tag that starts at `i` (just past the tag name),
-- skipping quoted attribute values and @( ... ) expressions.
local function tag_end(s, i)
	local depth, quote = 0, nil
	while i <= #s do
		local c = s:sub(i, i)
		if quote then
			if c == quote then
				quote = nil
			end
		elseif depth > 0 then
			if c == "(" then
				depth = depth + 1
			elseif c == ")" then
				depth = depth - 1
			end
		elseif c == '"' or c == "'" then
			quote = c
		elseif c == "@" and s:sub(i + 1, i + 1) == "(" then
			depth = 1
			i = i + 1
		elseif c == ">" then
			return i
		elseif c == "<" then
			return nil -- new tag before this one closed
		end
		i = i + 1
	end
end

local function check(buf)
	local s = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
	local diags = {}
	-- byte offset (1-based) -> 0-based row/col
	local line_starts = { 1 }
	for p in s:gmatch("()\n") do
		line_starts[#line_starts + 1] = p + 1
	end
	local function pos(off)
		local lo, hi = 1, #line_starts
		while lo < hi do
			local mid = math.ceil((lo + hi) / 2)
			if line_starts[mid] <= off then
				lo = mid
			else
				hi = mid - 1
			end
		end
		return lo - 1, off - line_starts[lo]
	end
	local function report(from, to, msg, sev)
		local lnum, col = pos(from)
		local end_lnum, end_col = pos(to + 1)
		diags[#diags + 1] = {
			lnum = lnum,
			col = col,
			end_lnum = end_lnum,
			end_col = end_col,
			severity = sev or vim.diagnostic.severity.ERROR,
			source = "razor-lint",
			message = msg,
		}
	end

	local stack = {}
	local i = 1
	while true do
		local lt = s:find("<", i, true)
		if not lt then
			break
		end
		local rest = s:sub(lt, lt + 3)
		local prev = lt > 1 and s:sub(lt - 1, lt - 1) or ""
		if rest == "<!--" then
			local e = s:find("-->", lt + 4, true)
			if not e then
				report(lt, lt + 3, "unterminated HTML comment")
				break
			end
			i = e + 3
		elseif prev:match("[%w_]") then
			i = lt + 1 -- generic in C# (List<string>), not a tag
		else
			local closing, name = s:match("^</?()([%a][%w:._-]*)", lt)
			local is_close = s:sub(lt + 1, lt + 1) == "/"
			if not name then
				i = lt + 1
			else
				local tag = name:lower()
				local name_end = lt + #name + (is_close and 1 or 0)
				local gt = tag_end(s, name_end + 1)
				if not gt then
					report(lt, name_end, "unterminated <" .. name .. "> tag")
					i = name_end + 1
				elseif is_close then
					local found
					for k = #stack, 1, -1 do
						if stack[k].tag == tag then
							found = k
							break
						end
					end
					if not found then
						report(lt, gt, "stray closing tag </" .. name .. ">")
					else
						for k = #stack, found + 1, -1 do
							local open = table.remove(stack, k)
							if not optional_end[open.tag] then
								report(open.from, open.to, "<" .. open.name .. "> closed by </" .. name .. "> before its own end tag")
							end
						end
						table.remove(stack, found)
					end
					i = gt + 1
				else
					local self_closing = s:sub(gt - 1, gt - 1) == "/"
					if not (self_closing or void[tag]) then
						stack[#stack + 1] = { tag = tag, name = name, from = lt, to = name_end }
					end
					i = gt + 1
					if raw_text[tag] and not self_closing then
						local e = s:lower():find("</" .. tag, i, true)
						if not e then
							break
						end
						i = e
					end
				end
			end
		end
	end
	for _, open in ipairs(stack) do
		if not optional_end[open.tag] then
			report(open.from, open.to, "unclosed <" .. open.name .. ">")
		end
	end
	vim.diagnostic.set(ns, buf, diags)
end

local M = {}

function M.setup()
	local group = vim.api.nvim_create_augroup("razor_lint", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = { "razor", "html" },
		callback = function(ev)
			if vim.bo[ev.buf].filetype == "html" and not vim.api.nvim_buf_get_name(ev.buf):match("%.cshtml?$") then
				return
			end
			if vim.b[ev.buf].razor_lint then
				return
			end
			vim.b[ev.buf].razor_lint = true
			local timer = assert(vim.uv.new_timer())
			local function run()
				if vim.api.nvim_buf_is_valid(ev.buf) then
					check(ev.buf)
				end
			end
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
				group = group,
				buffer = ev.buf,
				callback = function()
					timer:stop()
					timer:start(300, 0, vim.schedule_wrap(run))
				end,
			})
			vim.api.nvim_create_autocmd("BufWipeout", {
				group = group,
				buffer = ev.buf,
				callback = function()
					timer:stop()
					timer:close()
				end,
			})
			run()
		end,
	})
end

M.check = check
return M
