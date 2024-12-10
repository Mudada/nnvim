{ config, lib, pkgs, inputs, ... }:
let 
  system = "aarch64-darwin";
  treesitter-nu-grammar = pkgs.tree-sitter.buildGrammar {
    language = "nu";
    src = inputs.treesitter-nu-grammar;
    version = "";
  };
  toLuaFile = file: "${builtins.readFile file}";
in 
{
  options = {
    username = lib.mkOption {
      type = lib.types.enum ["gobmeboul" "tangui"];
    };
  };
  config = {

    home.username = toString config.username;
    home.homeDirectory = "/Users/${config.username}";

    home.stateVersion = "23.11"; 

    home.packages = [ 
      pkgs.ripgrep
      inputs.nv-dark-notify.packages.${system}.default
      pkgs.fd
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

    programs.starship = {
      enable = true;
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

# extra neovim plugins
    nixpkgs = {
      overlays = [
	(final: prev: {
	 vimPlugins = prev.vimPlugins // {
	 haskell-tools = prev.vimUtils.buildVimPlugin {
	 name = "haskell-tools";
	 src = inputs.nv-haskell-tools;
	 };
	 dark-notify = prev.vimUtils.buildVimPlugin {
	 name = "dark-notify";
	 src = inputs.nv-dark-notify;
	 };
	 nvim-nu = prev.vimUtils.buildVimPlugin {
	 name = "nvim-nu";
	 src = inputs.nvim-nu;
	 };
	 };
	 })
      ];
    };

    programs.nixvim =
    {
      config = { 
	enable = true;

	globals.mapleader = " ";

	opts = {
	  number = true;
	  relativenumber = true;
	  shiftwidth = 2;
	  clipboard = "unnamed";
	};

	colorschemes.catppuccin = {
	  enable = true;
	  settings = {
	    background = {
	      light = "latte";
	      dark = "mocha";
	    };
	    flavour = "mocha";
	    color_overrides = {
	      latte = {
		base = "#FDFFDF";
	      };
	    };
	  };
	};

	plugins.treesitter = { 
	  enable = true;
	  settings = {
	    highlight.enable = true;
	    indent.enable = true;
	  };
	  grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars ++ [
	    treesitter-nu-grammar
	  ];
	};

	plugins.which-key = {
	  enable = true;
	};

	plugins.lsp = {
	  enable = true;
	  servers = {
	    solargraph.enable = true;
	    lua_ls.enable = true;
	    nixd.enable = true;
	    hls = {
	      enable = true;
	      installGhc = false;
	    };
	    nushell = {
	      filetypes = ["nu"];
	      enable = true;
	    };
	    metals.enable = true;
	    rust_analyzer = {
	      installCargo = false;
	      installRustc = false;
	      enable = true;
	    };
	  };
	};

	plugins.telescope = {
	  enable = true;
	};

	plugins.mini = { 
	  enable = true; 
	  mockDevIcons = true;
	  modules.icons.enabled = true;
	};

	plugins.none-ls = {
	  enable = true;
	};

	keymaps = [
	{
	  key = "<leader>";
	  action = "<cmd>WhichKey <leader><cr>";
	}
	{
	  key = "<leader>ff";
	  action = "<cmd>lua require('telescope.builtin').find_files()<cr>";
	}
	{
	  key = "<leader>fg";
	  action = "<cmd>lua require('telescope.builtin').live_grep()<cr>";
	}
	{
	  key = "<leader>fb";
	  action = "<cmd>lua require('telescope.builtin').buffers()<cr>";
	}
	{
	  key = "<leader>fh";
	  action = "<cmd>lua require('telescope.builtin').help_tags()<cr>";
	}
	];

	plugins.luasnip.enable = true;
	plugins.cmp_luasnip.enable = true;


	plugins.cmp = {
	  enable = true;
	  autoEnableSources = true;
	};

	extraPlugins = with pkgs.vimPlugins; [
	  nvim-nu
	  dark-notify
	  haskell-tools
	  treesitter-nu-grammar
	];

	extraConfigLua = toLuaFile ./nvim/keybinds.lua;
      };
    };
  };
}
