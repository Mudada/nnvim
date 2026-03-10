{
  config,
  pkgs,
  username,
  inputs,
  ...
}:
{

  imports = [
    inputs.noctalia.homeModules.default
  ];

  config = {

    home.homeDirectory = "/home/${username}";

    home.packages = [
      pkgs.piper
      pkgs.slack
      pkgs.feh
      pkgs.shotman
      pkgs.wl-clipboard
      pkgs.cliphist
      pkgs.wtype
      pkgs.yazi
      pkgs.gimp
      pkgs.discord
    ];

    fonts.fontconfig.enable = true;

    home.file = {
    };

    home.sessionVariables = {
      AGENIX_IDENTITY = "${config.xdg.configHome}/age/keys.txt";
    };

    nixpkgs.config.allowUnfreePredicate = _: true;

    programs.home-manager.enable = true;

    programs.noctalia-shell.enable = true;

  };
}
