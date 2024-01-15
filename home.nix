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

  nixpkgs = {
    overlays = [
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          nvChad = prev.vimUtils.buildVimPlugin {
            name = "nvChad";
            src = inputs.nvChad;
          };
        };
       })
    ];
  };

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvChad;
      }
    ];

    extraPackages = with pkgs; [
      ripgrep
      libgcc
      gnumake
    ];
  };

}
