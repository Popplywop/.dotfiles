local module = {}
local gruber_darker_palette = {
  fg = "#e4e4ef",
  fgplus1 = "#f4f4ff",
  fgplus2 = "#f5f5f5",
  white = "#ffffff",
  black = "#000000",
  bgminus1 = "#101010",
  bg = "#181818",
  bgplus1 = "#282828",
  bgplus2 = "#453d41",
  bgplus3 = "#484848",
  bgplus4 = "#52494e",
  redminus1 = "#c73c3f",
  red = "#f43841",
  redplus1 = "#ff4f58",
  green = "#73c936",
  yellow = "#ffdd33",
  brown = "#cc8c3c",
  quartz = "#95a99f",
  niagaraminus1 = "#5f627f",
  niagara = "#96a6c8",
  wisteria = "#9e95c7"
}

function module.apply_to_config(config)
  config.color_scheme_dirs = { '/home/jpopple/.local/iTerm2-Color-Schemes/wezterm' }
  config.color_scheme = 'Gruber Darker'
  config.colors = {
    tab_bar = {
      background = gruber_darker_palette.bg,
      active_tab = {
        bg_color = gruber_darker_palette.bg,
        fg_color = gruber_darker_palette.yellow,
      },
      inactive_tab = {
        bg_color = gruber_darker_palette.bg,
        fg_color = gruber_darker_palette.wisteria,
      },
      inactive_tab_hover = {
        bg_color = gruber_darker_palette.bgplus1,
        fg_color = gruber_darker_palette.fg,
      },
      new_tab = {
        bg_color = gruber_darker_palette.bg,
        fg_color = gruber_darker_palette.yellow,
      },
      new_tab_hover = {
        bg_color = gruber_darker_palette.bgplus1,
        fg_color = gruber_darker_palette.fg,
      }
    }
  }
end

return module
