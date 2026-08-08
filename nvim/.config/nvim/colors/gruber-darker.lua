-- Native port of gruber-darker.nvim (https://github.com/gooseob/gruber-darker.nvim),
-- trimmed to the highlight groups we actually hit: core editor, treesitter,
-- diagnostics. No plugin-specific groups (telescope/neotree/rainbow) since
-- we don't run those plugins.

if vim.g.colors_name then
	vim.cmd("highlight clear")
end
vim.g.colors_name = "gruber-darker"
vim.o.termguicolors = true

local c = {
	fg = "#e4e4ef",
	fg_l1 = "#f4f4ff",
	fg_l2 = "#f5f5f5",
	white = "#ffffff",
	bg_d1 = "#101010",
	bg = "#181818",
	bg_l1 = "#282828",
	bg_l2 = "#453d41",
	bg_l4 = "#52494e",
	red = "#f43841",
	red_l1 = "#ff4f58",
	green = "#73c936",
	yellow = "#ffdd33",
	brown = "#cc8c3c",
	quartz = "#95a99f",
	niagara = "#96a6c8",
	wisteria = "#9e95c7",
}

local groups = {
	-- Core UI
	Comment = { fg = c.brown, italic = true },
	ColorColumn = { bg = c.bg_l2 },
	Conceal = { fg = c.fg, bg = c.bg },
	Cursor = { bg = c.yellow },
	lCursor = { fg = "NONE", bg = c.yellow },
	CursorLine = { bg = c.bg_l1 },
	CursorColumn = { bg = c.bg_l2 },
	Directory = { fg = c.niagara, bold = true },

	DiffAdd = { fg = c.green },
	DiffChange = { fg = c.yellow },
	DiffDelete = { fg = c.red_l1 },
	DiffText = { fg = c.yellow },

	EndOfBuffer = { fg = c.bg_l4 },
	TermCursor = { bg = c.yellow },
	ErrorMsg = { fg = c.white, bg = c.red },

	VertSplit = { fg = c.fg_l2, bg = c.bg_l1 },
	WinSeparator = { fg = c.bg_l2, bold = true },

	Folded = { fg = c.brown, bg = c.bg_l2, italic = true },
	FoldColumn = { fg = c.brown, bg = c.bg_l2 },
	SignColumn = { fg = c.bg_l2 },

	LineNr = { fg = c.bg_l4 },
	CursorLineNr = { fg = c.yellow },

	MatchParen = { fg = c.fg, bg = c.wisteria },
	ModeMsg = { fg = c.fg_l1 },
	MoreMsg = { fg = c.fg_l2 },
	NonText = { fg = c.bg_l4 },

	Normal = { fg = c.fg, bg = c.bg },
	NormalNC = { fg = c.fg, bg = c.bg },
	NormalSB = { fg = c.fg, bg = c.bg_d1 },
	NormalFloat = { fg = c.fg, bg = c.bg_l1 },
	FloatBorder = { fg = c.bg_l4 },

	Pmenu = { fg = c.fg, bg = c.bg_l1 },
	PmenuSel = { fg = c.fg, bg = c.bg_l2 },
	PmenuSbar = { bg = c.bg },
	PmenuThumb = { bg = c.bg },

	Question = { fg = c.niagara },
	QuickFixLine = { bg = c.bg_l2, bold = true },

	Search = { fg = "#000000", bg = c.yellow },
	IncSearch = { fg = "#000000", bg = c.fg_l2 },
	CurSearch = { fg = "#000000", bg = c.fg_l2 },

	SpecialKey = { fg = c.fg_l2 },
	SpellBad = { sp = c.red, underline = true },
	SpellCap = { undercurl = true },
	SpellLocal = { undercurl = true },
	SpellRare = { undercurl = true },

	StatusLine = { fg = c.white, bg = c.bg_l1 },
	StatusLineNC = { fg = c.quartz, bg = c.bg_l1 },

	TabLineFill = { fg = c.bg_l4, bg = c.bg_l1 },
	TabLineSel = { fg = c.yellow, bold = true },

	Title = { fg = c.quartz },
	Visual = { bg = c.bg_l2 },
	VisualNOS = { fg = c.red },
	WarningMsg = { fg = c.red },
	Whitespace = { fg = c.bg_l4 },
	WildMenu = { fg = "#000000", bg = c.yellow },

	-- Syntax
	Constant = { fg = c.quartz },
	String = { fg = c.green, italic = true },
	Character = { fg = c.green, italic = true },
	Number = { fg = c.wisteria },
	Boolean = { fg = c.yellow, bold = true },
	Float = { fg = c.wisteria },

	Identifier = { fg = c.fg_l1 },
	Function = { fg = c.niagara },

	Statement = { fg = c.yellow },
	Conditional = { fg = c.yellow, bold = true },
	Repeat = { fg = c.yellow, bold = true },
	Label = { fg = c.yellow, bold = true },
	Operator = { fg = c.fg },
	Keyword = { fg = c.yellow, bold = true },
	Exception = { fg = c.yellow, bold = true },

	PreProc = { fg = c.quartz },
	Include = { fg = c.quartz },
	Define = { fg = c.quartz },
	Macro = { fg = c.quartz },
	PreCondit = { fg = c.quartz },

	Type = { fg = c.quartz },
	StorageClass = { fg = c.yellow, bold = true },
	Structure = { fg = c.yellow, bold = true },
	Typedef = { fg = c.yellow, bold = true },

	Special = { fg = c.yellow },
	SpecialChar = { fg = c.yellow },
	Tag = { fg = c.yellow },
	Delimiter = { fg = c.fg },
	SpecialComment = { fg = c.wisteria, bold = true },
	Debug = { fg = c.fg_l2 },

	Underlined = { fg = c.wisteria, underline = true },
	Bold = { bold = true },
	Italic = { italic = true },
	Todo = { fg = c.bg, bg = c.yellow },

	markdownHeadingDelimiter = { fg = c.niagara, bold = true },
	markdownCode = { fg = c.green },
	markdownCodeBlock = { fg = c.green },
	markdownItalic = { fg = c.wisteria, italic = true },
	markdownBold = { fg = c.yellow, bold = true },
	markdownCodeDelimiter = { fg = c.brown, italic = true },
	markdownError = { fg = c.fg, bg = c.bg_l1 },

	-- Treesitter
	["@comment"] = { link = "Comment" },
	["@comment.documentation"] = { fg = c.green, italic = true },
	["@punctuation.delimiter"] = { link = "Delimiter" },
	["@punctuation.bracket"] = { fg = c.wisteria },
	["@punctuation.special"] = { fg = c.brown },
	["@string"] = { link = "String" },
	["@string.regex"] = { link = "Constant" },
	["@string.escape"] = { link = "Constant" },
	["@character"] = { link = "Character" },
	["@boolean"] = { link = "Boolean" },
	["@number"] = { link = "Number" },
	["@float"] = { link = "Float" },
	["@function"] = { link = "Function" },
	["@function.builtin"] = { fg = c.yellow },
	["@method"] = { link = "Function" },
	["@constructor"] = { link = "Function" },
	["@parameter"] = { link = "Identifier" },
	["@keyword"] = { link = "Keyword" },
	["@conditional"] = { fg = c.yellow },
	["@repeat"] = { link = "Repeat" },
	["@label"] = { link = "Label" },
	["@type"] = { link = "Type" },
	["@type.builtin"] = { link = "Type" },
	["@storageclass"] = { link = "StorageClass" },
	["@field"] = { fg = c.niagara },
	["@property"] = { link = "Normal" },
	["@variable"] = { link = "Identifier" },
	["@variable.builtin"] = { fg = c.yellow },
	["@constant"] = { link = "Constant" },
	["@constant.builtin"] = { fg = c.yellow },
	["@text.uri"] = { fg = c.niagara, underline = true },
	["@tag"] = { link = "Tag" },
	["@tag.attribute"] = { fg = c.niagara },
	["@tag.delimiter"] = { link = "Delimiter" },

	-- Diagnostics
	DiagnosticError = { fg = c.red, bold = true },
	DiagnosticSignError = { fg = c.red },
	DiagnosticUnderlineError = { sp = c.red, underline = true },
	DiagnosticWarn = { fg = c.yellow, bold = true },
	DiagnosticSignWarn = { fg = c.yellow },
	DiagnosticUnderlineWarn = { sp = c.yellow, underline = true },
	DiagnosticInfo = { fg = c.green, bold = true },
	DiagnosticSignInfo = { fg = c.green },
	DiagnosticUnderlineInfo = { sp = c.green, underline = true },
	DiagnosticHint = { fg = c.wisteria },
	DiagnosticSignHint = { fg = c.wisteria },
	DiagnosticUnderlineHint = { sp = c.wisteria, underline = true },
	DiagnosticUnnecessary = { sp = c.wisteria, underline = true },
}

for group, spec in pairs(groups) do
	vim.api.nvim_set_hl(0, group, spec)
end

local term_colors = {
	c.bg_l1,
	c.red_l1,
	c.green,
	c.yellow,
	c.niagara,
	c.wisteria,
	c.niagara,
	c.fg,
	c.bg_l1,
	c.red_l1,
	c.green,
	c.yellow,
	c.niagara,
	c.wisteria,
	c.niagara,
	c.fg,
}
for i, color in ipairs(term_colors) do
	vim.g["terminal_color_" .. (i - 1)] = color
end
