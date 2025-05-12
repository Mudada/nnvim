{ config, lib, pkgs, ... }:
let 
  toLuaFile = file: "${builtins.readFile file}";
  nix-metals-path = "${pkgs.metals}/bin/metals";
  system = "x86_64-linux";
in 
  {
  options = { 
    enable = lib.mkEnableOption "Home module";
    username = lib.mkOption {
      type = lib.types.enum ["gobmeboul" "tangui" "mudada"];
    };
  };
  imports = [];

  config = {

    home-manager.useUserPackages = true;

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
	      (pkgs.callPackage ./../monacob2/monacob2.nix {})
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

#   programs.nixvim =
#     {
#       config = { 
#         enable = true;
#
#         globals.mapleader = " ";
#
#         opts = {
#           number = true;
#           relativenumber = true;
#           shiftwidth = 2;
#           clipboard = "unnamed";
#         };
#
#         colorschemes.catppuccin = {
#           enable = true;
#           settings = {
#             background = {
#       	light = "latte";
#       	dark = "mocha";
#             };
#             flavour = "mocha";
#             color_overrides = {
#       	latte = {
#       	  base = "#FDFFDF";
#       	};
#             };
#           };
#         };
#
#         plugins.cmp-dap.enable = true;
#
#         plugins.dap-ui = {
#             enable = true;
#         };
#
#         plugins.dap = {
#           enable = true;
#           configurations = {
#             scala = [
#       	{
#       	  type = "scala";
#       	  name = "Run";
#       	  request = "launch";
#       	  metals = {
#       	    runType = "run";
#       	  };
#       	}
#             ];
#           };
#         };
#
#         plugins.treesitter = { 
#           enable = true;
#           settings = {
#             highlight.enable = true;
#             indent.enable = true;
#           };
#         };
#
#         plugins.fidget = {
#           enable = true;
#         };
#
#         plugins.which-key = {
#           enable = true;
#         };
#
#         plugins.lsp = {
#           enable = true;
#           servers = {
#             solargraph.enable = true;
#             lua_ls.enable = true;
#             nixd.enable = true;
#             hls = {
#       	enable = true;
#       	installGhc = false;
#             };
#             rust_analyzer = {
#       	installCargo = false;
#       	installRustc = false;
#       	enable = true;
#             };
#           };
#         };
#
#         plugins.telescope = {
#           enable = true;
#         };
#
#         plugins.mini = { 
#           enable = true; 
#           mockDevIcons = true;
#           modules.icons.enabled = true;
#         };
#
#         plugins.none-ls = {
#           enable = true;
#         };
#
#         keymaps = [
#           {
#             key = "<leader>";
#             action = "<cmd>WhichKey <leader><cr>";
#           }
#           {
#             key = "<leader>ff";
#             action = "<cmd>lua require('telescope.builtin').find_files()<cr>";
#           }
#           {
#             key = "<leader>fg";
#             action = "<cmd>lua require('telescope.builtin').live_grep()<cr>";
#           }
#           {
#             key = "<leader>fb";
#             action = "<cmd>lua require('telescope.builtin').buffers()<cr>";
#           }
#           {
#             key = "<leader>fh";
#             action = "<cmd>lua require('telescope.builtin').help_tags()<cr>";
#           }
#           ######## DAP ########
#           {
#             mode = "n";
#             key = "<leader>dtg";
#             action = ":DapToggleBreakpoint<cr>";
#           }
#           {
#             mode = "n";
#             key = "<leader>dro";
#             action = ":DapToggleRepl<cr>";
#           }
#           {
#             mode = "n";
#             key = "<leader>dso";
#             action = ":DapStepOver<cr>";
#           }
#           {
#             mode = "n";
#             key = "<leader>dsi";
#             action = ":DapStepInto<cr>";
#           }
#           {
#             mode = "n";
#             key = "<leader>dsu";
#             action = ":DapStepOut<cr>";
#           }
#           {
#             mode = "n";
#             key = "<leader>dc";
#             action = ":DapContinue<cr>";
#           }
#           {
#             mode = "n";
#             key = "<leader>dst";
#             action = ":DapTerminate<cr>";
#           }
#         ];
#
#         plugins.luasnip.enable = true;
#         plugins.cmp_luasnip.enable = true;
#
#
#         plugins.cmp = {
#           enable = true;
#           autoEnableSources = true;
#           settings.sources = [
#             { name = "nvim_lsp"; }
#             { name = "path"; 	 }
#             { name = "buffer"; 	 }
#             { name = "dap"; 	 }
#           ];
#           settings.mapping = {
#             "<C-Space>" = "cmp.mapping.complete()";
#             "<C-d>" = "cmp.mapping.scroll_docs(-4)";
#             "<C-e>" = "cmp.mapping.close()";
#             "<C-f>" = "cmp.mapping.scroll_docs(4)";
#             "<CR>" = "cmp.mapping.confirm({ select = true })";
#             "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
#             "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
#           };
#         };
#         extraPlugins = [
#           pkgs.vimPlugins.haskell-tools-nvim
#           pkgs.vimPlugins.nvim-metals
#           (pkgs.callPackage ./dark-notify.nix { })
#         ];
#
#         extraConfigLua = ''
#           vim.g.metals_executable_path = "${nix-metals-path}"
#           ${ toLuaFile ./nvim/keybinds.lua }
#           ${ toLuaFile ./nvim/metals.lua }
#         '';
#       };
#     };
  };
  }
