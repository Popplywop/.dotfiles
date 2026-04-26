local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local keys = require 'keys'
local colors = require 'colors'
local general = require 'general'

general.apply_to_config(config)
colors.apply_to_config(config)
keys.apply_to_config(config)

return config
