{
  config,
  pkgs,
  username,
  email,
  inputs,
  ...
}:
{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  home.stateVersion = "25.11";
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    ripgrep
    fd
    ragenix
    rage
    nixd
    wget
    htop
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = username;
      user.email = email;
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = username;
      user.email = email;
      ui.default-command = "log";
    };
  };

  programs.nushell = {
    enable = true;
    extraConfig = ''
      $env.PATH = ([$env.HOME + "/.nix-profile/bin" "/etc/profiles/per-user/${username}/bin"] ++ ($env.PATH | split row (char esep)))
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = config.age.secrets.ssh-personal.path;
      identitiesOnly = true;
    };
  };

  age.identityPaths = [
    "${config.xdg.configHome}/age/keys.txt"
  ];

  age.secrets.ssh-personal = {
    file = ../secrets/ssh-personal.age;
    path = "${config.home.homeDirectory}/.ssh/id_personal";
  };

  nixpkgs.config.allowUnfreePredicate = _: true;
}
