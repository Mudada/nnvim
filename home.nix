{ config, lib, pkgs, inputs, ... }:
let 
  toLuaFile = file: "${builtins.readFile file}";
  userScriptPath = "${config.home.homeDirectory}/scripts/${config.username}";
in 
  {
  options = {
    username = lib.mkOption {
      type = lib.types.enum ["gobmeboul" "tangui" "mudada"];
    };
    system = lib.mkOption {
      type = lib.types.enum ["aarch64-darwin" "x86_64-linux"];
    };
  };
  
  imports = [
    ./modules
  ];

  config = lib.mkMerge [
    {
      home.username = toString config.username;
      home.homeDirectory = "/Users/${config.username}";

      home.stateVersion = "23.11"; 

      home.packages = [ 
	pkgs.ripgrep
	inputs.nv-dark-notify.packages.${config.system}.default
	pkgs.metals
	pkgs.fd
	pkgs.pueue
	pkgs.coursier
	pkgs.zed-editor
	pkgs.pgcli
	pkgs._1password-cli
	pkgs.clever-tools
	pkgs.postgresql
	pkgs.vlc-bin
      ];

      home.sessionVariables = {
      };


      nixpkgs.config.allowUnfreePredicate = _: true;

      programs.home-manager.enable = true;

      programs.wezterm = {
	enable = true;
	extraConfig = ''
	  ${ toLuaFile ./wezterm/sessionizer.lua }
	  ${ toLuaFile ./wezterm/config.lua }
	conf.default_prog = {'${config.home.homeDirectory}/.nix-profile/bin/nu'}
	return(conf)
	'';
      };

      programs.nushell = {
	enable = true;
	configFile.source = ./modules/nushell/config.nu;
	envFile.source = ./modules/nushell/env.nu;
	extraConfig = "source ${userScriptPath}.nu"; # TODO: lib.mkIf (builtins.pathExists userScriptPath) "source ${userScriptPath}.nu";
	plugins = [
	  pkgs.nushellPlugins.formats
	];
      };

      home.file = {
	"scripts" = {
	  source = ./scripts;
	  recursive = true;
	};
      };

      programs.direnv = {
	enable = true;
	enableNushellIntegration = true;
	nix-direnv.enable = true;
      };

      programs.starship = {
	enable = true;
	enableNushellIntegration = true;
	settings = {
	  add_newline = true;
	};
      };

      programs.bat = {
	enable = true;
      };

      programs.tmux = {
	enable = true;
      };

      programs.jq = {
	enable = true;
      };

      programs.git = {
	enable = true;
	userName = "Tangui";
	userEmail = "mael.nicolas@clever-cloud.com";
      };

      programs.zed-editor = {
	package = pkgs.unstable.zed-editor;
	installRemoteServer = true;
	extraPackages = with pkgs; [
	  nil
	  nixd
	  nixfmt-rfc-style
	];
      };

      home.shellAliases = {
	zed = "zeditor";
      };

      xdg.configFile."zed/settings.json" = {
	source = ./zed.json;
      };
    }
  ];
}
