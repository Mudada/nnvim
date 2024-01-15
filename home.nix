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

    colorschemes.catppuccin = {
      enable = true;
      flavour = "latte";
      colorOverrides = {
	all = {
	  base = "#FDFFDF";
	};
      };
    };

    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };
  };
}
