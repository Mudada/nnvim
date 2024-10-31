{ config, pkgs, inputs, ... }:
let 
   treesitter-nu-grammar = pkgs.tree-sitter.buildGrammar {
     language = "nu";
     src = inputs.treesitter-nu-grammar;
     version = "";
   };
in 
{

  home.username = "tangui";
  home.homeDirectory = "/Users/tangui";

  home.stateVersion = "23.11"; 

# nix = {
#   package = pkgs.nix;
#   settings.experimental-features = ["nix-command" "flakes"];
#   settings.extra-platforms = ["aarch64-darwin" "x86_64-darwin"];
#   settings.extra-substituters = ["https://cache.iog.io"];
#   settings.extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
#   settings.allow-import-from-derivation = "true";
# };

  home.packages = with pkgs; [ 
    ripgrep
  ];

  home.file = {
  };

  home.sessionVariables = {
  };


  nixpkgs.config.allowUnfreePredicate = _: true;

  programs.home-manager.enable = true;

  programs.nushell = {
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
    let
    toLuaFile = file: "${builtins.readFile file}";
  in
  { 
    enable = true;

    globals.mapleader = " ";

    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      clipboard = "unnamed";
    };

    colorschemes.catppuccin = {
      enable = true;
      flavour = "mocha";
      background = {
	light = "latte";
	dark = "mocha";
      };
      colorOverrides = {
	latte = {
	  base = "#FDFFDF";
	};
      };
    };

    plugins.treesitter = { 
      enable = true;
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
	lua-ls.enable = true;
	nixd.enable = true;
	hls.enable = true;
	nushell = {
	  filetypes = ["nu"];
	  enable = true;
	};
	metals.enable = true;
	rust-analyzer = {
	  installCargo = false;
	  installRustc = false;
	  enable = true;
	};
      };
    };

    plugins.telescope = {
      enable = true;
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

    plugins.nvim-cmp = {
      enable = true;
      autoEnableSources = true;
      sources = [
      {name = "nvim_lsp";}
      {name = "path";}
      {name = "buffer";}
      ];
      snippet.expand = "luasnip";

      mapping = {
	"<CR>" = "cmp.mapping.confirm({ select = true })";
	"<Tab>" = {
	  action = ''
	    function(fallback)
	    if cmp.visible() then
	      cmp.select_next_item()
	    else
	      fallback()
		end
		end
		'';
	  modes = [ "i" "s" ];
	};
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
	haskell-tools
	nvim-nu
	dark-notify
	treesitter-nu-grammar
    ];

    extraConfigLua = toLuaFile ./nvim/keybinds.lua;
  };
}
