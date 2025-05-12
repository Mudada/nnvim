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
    return 'rose-pine-dawn'
  end
end

local rosePineDawn = wezterm.color.get_builtin_schemes()['rose-pine-dawn']
rosePineDawn.selection_bg = "#56949f"
conf.color_schemes = {
  ['rose-pine-dawn'] = rosePineDawn
}
conf.color_scheme = scheme_for_appearance(get_appearance())

-- Common config
conf.font_size = 12
conf.window_background_opacity = 1
conf.hide_tab_bar_if_only_one_tab = true
conf.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }
conf.front_end = "WebGpu"
conf.font = wezterm.font_with_fallback {
  { family = 'MonacoB2', weight = 'Bold' },
  { family = 'Nanum Gothic', weight = 'DemiBold', scale = 1.2 }
  -- { family = "카페24동동OTF", scale = 1.2 }
}
conf.adjust_window_size_when_changing_font_size = false
conf.bypass_mouse_reporting_modifiers = "SHIFT"
conf.audible_bell = "Disabled"

-- Window management
--
local function activate_tab(key, index)
	return {
		key = key,
		mods = "ALT",
		action = wezterm.action.ActivateTab(index),
	}
end

local function change_focus(key, direction)
	return {
		key = key,
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection(direction),
	}
end

local function resize_pane(key, direction)
	return {
		key = key,
		mods = "SHIFT|ALT",
		action = wezterm.action.AdjustPaneSize({ direction, 2 }),
	}
end

local function rename_tab()
	return wezterm.action.PromptInputLine({
		description = "Rename tab",
		action = wezterm.action_callback(function(window, _, line)
			if line then
				window:active_tab():set_title(line)
			end
		end),
	})
end

conf.keys = {
	-- tabs
	{ key = "t", mods = "ALT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	activate_tab("`", 0),
	activate_tab("1", 1),
	activate_tab('2', 2),
	activate_tab("3", 3),
	activate_tab("4", 4),
	activate_tab("5", 5),
	activate_tab("q", 6),
	activate_tab("w", 7),
	activate_tab("e", 8),
	activate_tab("r", 9),
	{ key = "r", mods = "ALT", action = rename_tab() },

	-- panes
	{ key = "n", mods = "ALT", action = wezterm.action.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
	{ key = "b", mods = "ALT", action = wezterm.action.SplitPane({ direction = "Down", size = { Percent = 50 } }) },
	{ key = "z", mods = "ALT", action = wezterm.action.TogglePaneZoomState },
	{ key = "x", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	change_focus("h", "Left"),
	change_focus("j", "Down"),
	change_focus("k", "Up"),
	change_focus("l", "Right"),
	resize_pane("h", "Left"),
	resize_pane("j", "Down"),
	resize_pane("k", "Up"),
	resize_pane("l", "Right"),

	-- other stuff
	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
	{ key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
	{ key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
	{ key = "C", mods = "CTRL", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "V", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
--	{ key = "f", mods = "ALT", action = sessionizer.sessionize() },
	{ key = "L", mods = "ALT", action = wezterm.action.ShowDebugOverlay },
	{ key = "p", mods = "ALT", action = wezterm.action.ActivateCommandPalette },
	{ key = "w", mods = "ALT", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{ key = "U", mods = "ALT", action = wezterm.action.ScrollByPage(-1) },
	{ key = "u", mods = "ALT", action = wezterm.action.ScrollByLine(-1) },
	{ key = "D", mods = "ALT", action = wezterm.action.ScrollByPage(1) },
	{ key = "d", mods = "ALT", action = wezterm.action.ScrollByLine(1) },
}

