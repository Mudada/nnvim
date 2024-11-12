-- Gonna be read by home-manager, adding params to conf

local wezterm = require 'wezterm'
local conf = wezterm.config_builder()

-- Color scheme
local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

local function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Catppuccin Mocha'
  else
    return 'Catppuccin Latte'
  end
end

conf.color_schemes = {
  ["Catppuccin Latte"] = {
    background = "#FDFFDF",
    foreground = "black"
  }
}
conf.color_scheme = scheme_for_appearance(get_appearance())

-- Common config
conf.font_size = 16
conf.window_background_opacity = 1
conf.hide_tab_bar_if_only_one_tab = true
conf.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }
conf.front_end = "WebGpu"
conf.font = wezterm.font('MonacoB2', { weight = 'Bold' })


