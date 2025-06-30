{ config, lib, pkgs, username, system, inputs, ... }:
let 
  toLuaFile = file: "${builtins.readFile file}";
in 
  {
  options = { 
    enable = lib.mkEnableOption "Home module";
    username = lib.mkOption {
      type = lib.types.enum ["gobmeboul" "tangui" "mudada"];
    };
  };

  imports = [
  ];

  config = {

    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";

    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "${username}" ];
    };

    environment.etc = {
      "1password/custom_allowed_browsers" = {
	text = ''
	  zen-browser
	'';
	mode = "0755";
      };
    };

    home-manager.users.${config.username} = {
      home.username = "${config.username}";
      home.homeDirectory = "/home/${config.username}";

      home.stateVersion = "23.11"; 

      home.packages = [ 
	pkgs.ripgrep
	pkgs.metals
	pkgs.fd
	pkgs.pueue
	pkgs.coursier
	pkgs.zed-editor
	pkgs.vesktop
	pkgs.slack
	pkgs.ripgrep
	pkgs.pgcli
	pkgs.feh
	pkgs.shotman
	pkgs.wl-clipboard
	pkgs.cliphist
	pkgs.wtype
	(pkgs.callPackage ./../monacob2/monacob2.nix {})
	inputs.zen-browser.packages."${system}".default
	##      (pkgs.buildFHSEnv {
	##	name = "zed";
	##	targetPkgs = pkgs: [
	##	  inputs.nix-metals.packages
	##	  pkgs.zed-editor
	##	];
	##	runScript = "zed";
	##      })
      ];

      fonts.fontconfig.enable = true;

      home.file = {
      };

      home.sessionVariables = {
      };


      nixpkgs.config.allowUnfreePredicate = _: true;

      programs.home-manager.enable = true;

      programs.wezterm = {
	enable = true;
	#${ toLuaFile ../../wezterm/sessionizer.lua }
	extraConfig = ''
	  ${ toLuaFile ../../wezterm/config.lua }
	      conf.default_prog = {'${pkgs.nushell}/bin/nu'}
	      return(conf)
	'';
      };

      programs.nushell = {
	enable = true;
	configFile.source = ../../nushell/config.nu;
	envFile.source = ../../nushell/env.nu;
	extraConfig = ''
		source ~/scripts/${username}.nu
	'';
      };

      home.file = {
	"scripts" = {
	  source = ../../scripts;
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
  };
}
