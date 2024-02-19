{ config, pkgs, inputs, ... }:

{

  home.username = "gobmeboul";
  home.homeDirectory = "/Users/gobmeboul";

  home.stateVersion = "23.11"; 

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
    settings.extra-platforms = ["aarch64-darwin" "x86_64-darwin"];
  };

  home.packages = [ 
    pkgs.ripgrep
  ];

  home.file = {
  };

  home.sessionVariables = {
  };

  programs.home-manager.enable = true;

  programs.nushell = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Mudada";
    userEmail = "mael.nicolas77@gmail.com";
  };

  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";

    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };

    colorschemes.catppuccin = {
      enable = true;
      flavour = "latte";
      colorOverrides = {
	all = {
	  base = "#FDFFDF";
	};
      };
    };

    plugins.lsp = {
      enable = true;
      servers = {
	lua-ls.enable = true;
	nixd.enable = true;
      };
    };

    plugins.telescope = {
      enable = true;
    };
    keymaps = [
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

    plugins.nvim-cmp = {
      enable = true;
      autoEnableSources = true;
      sources = [
	{name = "nvim_lsp";}
	{name = "path";}
	{name = "buffer";}
      ];

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
      
    ];
  };
}
