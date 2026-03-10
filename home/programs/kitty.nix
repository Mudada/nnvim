{
  username,
  ...
}:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "monospace";
      size = 12;
    };
    settings = {
      shell = "/etc/profiles/per-user/${username}/bin/nu";
      editor = "hx";
      enabled_layouts = "splits";
      hide_window_decorations = "titlebar-only";
      window_padding_width = 4;
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      macos_option_as_alt = true;
      macos_quit_when_last_window_closed = true;
    };
    keybindings = {
      # Vertical split
      "opt+v" = "launch --location=vsplit";
      # Close panel
      "opt+x" = "close_window";
      # Tab switching with cmd+number
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";
      # New tab
      "cmd+t" = "new_tab";
      # Close tab
      "cmd+w" = "close_tab";
    };
  };

  home.file = {
    ".config/kitty/dark-theme.auto.conf".source = ./kitty/rose-pine-dark.conf;
    ".config/kitty/light-theme.auto.conf".source = ./kitty/rose-pine-light.conf;
  };
}
