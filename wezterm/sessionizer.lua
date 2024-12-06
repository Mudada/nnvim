local wezterm = require("wezterm")
local sessionizer = {}

function sessionizer.sessionize()
  local choices = {}
  local home = os.getenv("HOME")
  local fd = home .. "/.nix-profile/bin/fd"
  local success, stdout, stderr = wezterm.run_child_process({
    fd,
    ".",
    home .. "/.config/home-manager",
    home .. "/Code",
    home .. "/Note",
    "--min-depth",
    "1",
    "--max-depth",
    "1",
    "--type",
    "d",
  })

  if not success then
    wezterm.log_error("Failed to run fd: " .. stderr)
    return
  end

  stdout = home .. "/.config/home-manager\n" .. stdout
  for directory in stdout:gmatch("[^\n]+") do
    local session_name = directory:match("([^/]+)/$")
    table.insert(choices, { id = session_name, label = directory })
  end

  return wezterm.action.InputSelector({
    title = "Sessionizer",
    choices = choices,
    fuzzy = true,
    action = wezterm.action_callback(function(child_window, child_pane, id, label)
      if not label then
	wezterm.log_info("Cancelled")
	return
      end

      local msg = string.format("Creating session [%s] in directory [%s]", id, label)
      wezterm.log_info(msg)
      child_window:perform_action(
      wezterm.action.SwitchToWorkspace({
	name = id,
	spawn = { cwd = label },
      }),
      child_pane
      )
    end),
  })
end

