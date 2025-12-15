# Qutebrowser config - Gruvbox Dark (Hard Contrast)
# Matches Neovim gruvbox.nvim setup

config.load_autoconfig(False)

# =============================================================================
# Gruvbox Dark Hard Palette
# =============================================================================
bg_hard = "#1d2021"
bg = "#282828"
bg_soft = "#32302f"
bg1 = "#3c3836"
bg2 = "#504945"
bg3 = "#665c54"
bg4 = "#7c6f64"

fg = "#ebdbb2"
fg0 = "#fbf1c7"
fg1 = "#ebdbb2"
fg2 = "#d5c4a1"
fg3 = "#bdae93"
fg4 = "#a89984"

red = "#fb4934"
green = "#b8bb26"
yellow = "#fabd2f"
blue = "#83a598"
purple = "#d3869b"
aqua = "#8ec07c"
orange = "#fe8019"

red_dim = "#cc241d"
green_dim = "#98971a"
yellow_dim = "#d79921"
blue_dim = "#458588"
purple_dim = "#b16286"
aqua_dim = "#689d6a"
orange_dim = "#d65d0e"

# =============================================================================
# Tab Bar - Left Side
# =============================================================================
c.tabs.position = "left"
c.tabs.width = 200
c.tabs.padding = {"top": 4, "bottom": 4, "left": 8, "right": 8}
c.tabs.indicator.width = 3
c.tabs.favicons.scale = 1.0
c.tabs.title.format = "{audio}{current_title}"
c.tabs.show = "multiple"

# Tab colors
c.colors.tabs.bar.bg = bg_hard
c.colors.tabs.odd.bg = bg_hard
c.colors.tabs.odd.fg = fg4
c.colors.tabs.even.bg = bg_hard
c.colors.tabs.even.fg = fg4
c.colors.tabs.selected.odd.bg = bg1
c.colors.tabs.selected.odd.fg = fg
c.colors.tabs.selected.even.bg = bg1
c.colors.tabs.selected.even.fg = fg
c.colors.tabs.indicator.start = blue
c.colors.tabs.indicator.stop = aqua
c.colors.tabs.indicator.error = red
c.colors.tabs.pinned.odd.bg = bg_hard
c.colors.tabs.pinned.odd.fg = aqua
c.colors.tabs.pinned.even.bg = bg_hard
c.colors.tabs.pinned.even.fg = aqua
c.colors.tabs.pinned.selected.odd.bg = bg1
c.colors.tabs.pinned.selected.odd.fg = fg
c.colors.tabs.pinned.selected.even.bg = bg1
c.colors.tabs.pinned.selected.even.fg = fg

# =============================================================================
# Status Bar
# =============================================================================
c.colors.statusbar.normal.bg = bg_hard
c.colors.statusbar.normal.fg = fg
c.colors.statusbar.insert.bg = green_dim
c.colors.statusbar.insert.fg = bg
c.colors.statusbar.passthrough.bg = blue_dim
c.colors.statusbar.passthrough.fg = fg
c.colors.statusbar.command.bg = bg_hard
c.colors.statusbar.command.fg = fg
c.colors.statusbar.command.private.bg = purple_dim
c.colors.statusbar.command.private.fg = fg
c.colors.statusbar.caret.bg = purple_dim
c.colors.statusbar.caret.fg = fg
c.colors.statusbar.caret.selection.bg = purple_dim
c.colors.statusbar.caret.selection.fg = fg
c.colors.statusbar.url.fg = fg
c.colors.statusbar.url.success.http.fg = aqua
c.colors.statusbar.url.success.https.fg = green
c.colors.statusbar.url.error.fg = red
c.colors.statusbar.url.warn.fg = yellow
c.colors.statusbar.url.hover.fg = aqua
c.colors.statusbar.progress.bg = green

# =============================================================================
# Completion Menu
# =============================================================================
c.colors.completion.category.bg = bg_hard
c.colors.completion.category.fg = yellow
c.colors.completion.category.border.bottom = bg_hard
c.colors.completion.category.border.top = bg_hard
c.colors.completion.fg = fg
c.colors.completion.odd.bg = bg
c.colors.completion.even.bg = bg
c.colors.completion.item.selected.bg = bg2
c.colors.completion.item.selected.fg = fg
c.colors.completion.item.selected.border.bottom = bg2
c.colors.completion.item.selected.border.top = bg2
c.colors.completion.item.selected.match.fg = orange
c.colors.completion.match.fg = orange
c.colors.completion.scrollbar.bg = bg
c.colors.completion.scrollbar.fg = fg4

# =============================================================================
# Hints (Link Following)
# =============================================================================
c.colors.hints.bg = yellow
c.colors.hints.fg = bg_hard
c.colors.hints.match.fg = bg2
c.hints.border = f"1px solid {orange}"
c.hints.radius = 3

# =============================================================================
# Downloads
# =============================================================================
c.colors.downloads.bar.bg = bg_hard
c.colors.downloads.start.bg = blue
c.colors.downloads.start.fg = bg
c.colors.downloads.stop.bg = green
c.colors.downloads.stop.fg = bg
c.colors.downloads.error.bg = red
c.colors.downloads.error.fg = fg

# =============================================================================
# Messages / Prompts
# =============================================================================
c.colors.messages.error.bg = red
c.colors.messages.error.fg = fg
c.colors.messages.error.border = red_dim
c.colors.messages.warning.bg = orange
c.colors.messages.warning.fg = bg
c.colors.messages.warning.border = orange_dim
c.colors.messages.info.bg = bg
c.colors.messages.info.fg = fg
c.colors.messages.info.border = bg1
c.colors.prompts.bg = bg
c.colors.prompts.fg = fg
c.colors.prompts.border = f"1px solid {bg1}"
c.colors.prompts.selected.bg = bg2
c.colors.prompts.selected.fg = fg

# =============================================================================
# Keyhint Widget
# =============================================================================
c.colors.keyhint.bg = f"rgba(29, 32, 33, 0.9)"
c.colors.keyhint.fg = fg
c.colors.keyhint.suffix.fg = yellow

# =============================================================================
# Context Menu
# =============================================================================
c.colors.contextmenu.menu.bg = bg
c.colors.contextmenu.menu.fg = fg
c.colors.contextmenu.selected.bg = bg2
c.colors.contextmenu.selected.fg = fg
c.colors.contextmenu.disabled.bg = bg1
c.colors.contextmenu.disabled.fg = fg4

# =============================================================================
# Webpage
# =============================================================================
c.colors.webpage.bg = bg
c.colors.webpage.preferred_color_scheme = "dark"

# =============================================================================
# Fonts
# =============================================================================
c.fonts.default_family = "JetBrainsMono Nerd Font"
c.fonts.default_size = "11pt"
c.fonts.completion.entry = "11pt default_family"
c.fonts.completion.category = "bold 11pt default_family"
c.fonts.statusbar = "11pt default_family"
c.fonts.tabs.selected = "11pt default_family"
c.fonts.tabs.unselected = "11pt default_family"
c.fonts.hints = "bold 10pt default_family"

# =============================================================================
# General Settings
# =============================================================================
c.scrolling.smooth = True
c.content.autoplay = False
c.url.default_page = "about:blank"
c.url.start_pages = ["about:blank"]

# Search engines
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "g": "https://google.com/search?q={}",
    "gh": "https://github.com/search?q={}",
    "yt": "https://youtube.com/results?search_query={}",
    "r": "https://reddit.com/search?q={}",
    "aw": "https://wiki.archlinux.org/?search={}",
}

# =============================================================================
# Keybindings
# =============================================================================
# Bitwarden integration - opens rofi picker to select and fill credentials
config.bind("zl", "spawn --userscript bitwarden", mode="normal")
