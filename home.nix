{ config, lib, pkgs, inputs, ... }:
let 
  system = "aarch64-darwin";
  toLuaFile = file: "${builtins.readFile file}";
in 
  {
  options = {
    username = lib.mkOption {
      type = lib.types.enum ["gobmeboul" "tangui" "mudada"];
    };
  };
  
  imports = [
    ./modules {inherit pkgs; }
  ];

  config = {

    home.username = toString config.username;
    home.homeDirectory = "/Users/${config.username}";

    home.stateVersion = "23.11"; 

    home.packages = [ 
      pkgs.ripgrep
      inputs.nv-dark-notify.packages.${system}.default
      pkgs.metals
      pkgs.fd
      pkgs.pueue
      pkgs.coursier
      pkgs.zed-editor
    ];

    home.file = {
    };

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
      configFile.source = ./nushell/config.nu;
      envFile.source = ./nushell/env.nu;
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
	git_branch = {
	  symbol = "|";
	  format = "[$symbol$branch(:$remote_branch)]($style) ";
	};
	nix_shell = {
	  symbol = "*";
	  format = "[$symbol$state\\($name\\)]($style) ";
	};
	format = lib.strings.concatStrings [
	  "$username"
	  "$hostname"
	  "$localip"
	  "$directory"
	  "$git_branch"
	  "$git_commit"
	  "$git_state"
	  "$git_metrics"
	  "$git_status"
	  "$nix_shell"
	  "$direnv"
	  "$line_break"
	  "$character"
	];
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
  };
}
