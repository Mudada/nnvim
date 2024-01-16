{ config, pkgs, inputs, ... }:

{

  home.username = "gobmeboul";
  home.homeDirectory = "/home/gobmeboul";

  home.stateVersion = "23.11"; 

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  home.packages = [ 
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

    plugins.telescope.enable = true;

    plugins.lsp = {
      enable = true;
      servers = {
	lua-ls.enable = true;
	nixd.enable = true;
      };
    };

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
      nvchad
    ];
  };
}
