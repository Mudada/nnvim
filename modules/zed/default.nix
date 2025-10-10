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
	theme = {
	  mode = "system";
	  light = "Nanowise Light";
	  dark = "Nanowise Galaxy";
	};
	assistant = {
	  enabled = true;
	  default_model = {
	    provider = "zed.dev";
	    model = "claude-sonnet-4";
	  };
	};
	terminal = {
	  font_family = "MonacoB2";
	  shell = {
	    program = "nu";
	  };
	};
      };
    };
  };
}
