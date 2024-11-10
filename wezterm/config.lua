-- Gonna be read by home-manager, DO NOT RETURN ANYTHING

local wezterm = require 'wezterm'

local conf = wezterm.config_builder()

function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Catppuccin Mocha'
  else
    return 'Colorcli (Gogh)'
  end
end

conf.font_size = 16
conf.window_background_opacity = 1
conf.hide_tab_bar_if_only_one_tab = true
local theme = wezterm.plugin.require('https://github.com/neapsix/wezterm').dawn
conf.color_schemes = {
  ["Catppuccin Latte"] = {
    background = "#fbfee9",
    foreground = "black"
  }
}
conf.color_scheme = scheme_for_appearance(get_appearance())
conf.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }
conf.front_end = "WebGpu"
conf.font = wezterm.font('MonacoB2', { weight = 'Bold' })
