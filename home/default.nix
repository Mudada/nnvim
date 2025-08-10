{ config, pkgs, inputs, username, sys, ... }:
let 
  toLuaFile = file: "${builtins.readFile file}";
  userScriptPath = "${config.home.homeDirectory}/scripts/${username}";
  systemHome = if sys == "aarch64-darwin" then ./osx.nix else ./linux.nix;
in
  {
  imports = [
    systemHome
    ../modules/zen.nix 
  ];

  home.stateVersion = "25.11";
  home.username = username;

  home.packages = [ 
    pkgs.ripgrep
    pkgs.metals
    pkgs.fd
    pkgs.pueue
    pkgs.coursier
    pkgs.zed-editor
    pkgs.ripgrep
    pkgs.pgcli
    pkgs.gimp
    (pkgs.callPackage ./../modules/monacob2.nix {})
    pkgs.wezterm
  ];

  programs.zen-browser.enable = true;

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      ${ toLuaFile ../wezterm/config.lua }
	conf.default_prog = {'/etc/profiles/per-user/${username}/bin/nu'}
	return(conf)
    '';
  };

  programs.nushell = {
    enable = true;
    configFile.source = ../modules/nushell/config.nu;
    envFile.source = ../modules/nushell/env.nu;
    extraEnv = '' 
      let username = "${username}"
      $env.PATH = ($env.PATH ++ [
	$"/etc/profiles/per-user/($username)/bin"
	$"/Users/($username)/.nix-profile/bin"
      ])
    '';
    extraConfig = ''
      source ${userScriptPath}.nu
    ''; # TODO: lib.mkIf (builtins.pathExists userScriptPath) "source ${userScriptPath}.nu";
  };

  home.file = {
    "scripts" = {
      source = ../scripts;
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
    userName = "Mudada";
    userEmail = "mael.nicolas77@gmail.com";
  };
}
