{ config, pkgs, lib, ... }:

let
  cfg = config.programs.zed-editor;
in
  {
  options.programs.zed-editor = {
    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.home.shell.enableNushellIntegration;
    };
  };

  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      zed = "zeditor";
    };

    programs.zed-editor = {
      package = pkgs.zed-editor;
      installRemoteServer = true;
      extraPackages = with pkgs; [
	nil
	nixd
	nixfmt-rfc-style
      ];

      extensions = [
	"html"
	"scala"
	"toml"
	"nix"
	"nu"
      ];

      themes = {
	"Nanowise" = ./Nanowise.json;
	"Catppuccin" = ./Catppuccin.json;
	"Everforest" = ./EverforestDHBlur.json;
      };

      userSettings = {
	vim_mode = true;
	ui_font_size = 14;
	buffer_font_size = 14;
	show_whitespaces = "all" ;
	format_on_save = "on";
	## tell zed to use direnv and direnv can use a flake.nix enviroment.
	load_direnv = "shell_hook";
	auto_update = false;
	tab_bar = {
	  show = false;
	};
	theme = {
	  mode = "system";
	  light = "Everforest Dark Medium";
	  dark = "Everforest Dark Medium";
	};
	terminal = {
	  font_family = "MonacoB2";
	  shell = {
	    program = "nu";
	  };
	};
      };

      userKeymaps = [
	{
	  "context" = "EmptyPane || SharedScreen || Editor && VimControl && !VimWaiting && !menu";
	  "bindings" = {
	    "space space" = "file_finder::Toggle";
	    "space f f"   = "file_finder::Toggle";
	    "space f g"   = "pane::DeploySearch";
	    "space ," 	  = "tab_switcher::Toggle";
	    "space /" 	  = "workspace::NewSearch";
	    "space o l"   = "workspace::ToggleLeftDock";
	    "space o r"   = "workspace::ToggleRightDock";
	    "space o a"   = "agent::ToggleFocus";
	    "space o c"   = "collab_panel::ToggleFocus";
	    "space o o"   = "outline_panel::ToggleFocus";
	    "space o f"   = "project_panel::ToggleFocus";
	    "space o p"   = "projects::OpenRecent";
	    "space o t"   = "terminal_panel::ToggleFocus";
	    "space g g"   = "git::Diff";
	    "space w v"   = "pane::SplitRight";
	    "space w h"   = "workspace::ActivatePaneLeft";
	    "space w l"   = "workspace::ActivatePaneRight";
	    "space w k"   = "workspace::ActivatePaneUp";
	    "space w j"   = "workspace::ActivatePaneDown";
	    "space w z"   = "workspace::ToggleZoom";
	    "space q q"   = "zed::Quit";
	    "ctrl-w z"    = "workspace::ToggleZoom";
	    "ctrl-w t"    = "terminal_panel::ToggleFocus";
	    "ctrl-`" 	  = "workspace::ToggleBottomDock";
	  };
	}
      ];
    };
  };
}
