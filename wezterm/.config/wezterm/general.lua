local wezterm = require 'wezterm'
local module = {}

function module.apply_to_config(config)
  config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold', italic = false })
  config.font_size = 13

  config.enable_tab_bar = false
  config.disable_default_key_bindings = true

  config.unix_domains = {
    {
      name = 'unix',
    },
  }
  config.default_gui_startup_args = { 'connect', 'unix' }

  config.window_decorations = 'NONE'
  config.adjust_window_size_when_changing_font_size = false

  config.front_end = 'OpenGL'
  config.enable_wayland = true
end

return module
