{ pkgs, username, ... }:
{

  imports = [
  ];

  config = {

    home.homeDirectory = "/home/${username}";

    home.packages = [
      pkgs.piper
      pkgs.ripgrep
      pkgs.metals
      pkgs.fd
      pkgs.pueue
      pkgs.coursier
      pkgs.slack
      pkgs.ripgrep
      pkgs.pgcli
      pkgs.feh
      pkgs.shotman
      pkgs.wl-clipboard
      pkgs.cliphist
      pkgs.wtype
      pkgs.yazi
      pkgs.gimp
      (pkgs.callPackage ../modules/monacob2.nix { })
    ];
    
    fonts.fontconfig.enable = true;

    home.file = {
    };

    home.sessionVariables = {
    };

    nixpkgs.config.allowUnfreePredicate = _: true;

    programs.home-manager.enable = true;

  };
}
