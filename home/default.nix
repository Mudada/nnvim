{
  config,
  pkgs,
  username,
  sys,
  inputs,
  ...
}:
let
  systemHome = if sys == "aarch64-darwin" then ./osx.nix else ./linux.nix;
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
    systemHome
    ./programs/zen.nix
    ./programs/zed
    ./programs/helix.nix
    ./programs/kitty.nix
    ./programs/wezterm.nix
    ./programs/nushell.nix
    ./programs/shell.nix
    ./programs/git.nix
  ];

  home.stateVersion = "25.11";
  home.username = username;

  home.packages = [
    pkgs.ripgrep
    pkgs.metals
    pkgs.fd
    pkgs.pueue
    pkgs.coursier
    pkgs.pgcli
    (pkgs.callPackage ./../packages/monacob2.nix { })
    pkgs.ragenix
    pkgs.rage
    pkgs.claude-code
    pkgs.nixd
    pkgs.anki-bin
    pkgs.rustup
    pkgs.signal-desktop
  ];

  programs.zen-browser = {
    enable = true;
  };

  programs.zed-editor.enable = true;

  home.file = {
    "scripts" = {
      source = ../scripts;
      recursive = true;
    };
    ".claude/settings.json".text = builtins.toJSON {
      includeCoAuthoredBy = false;
    };
  };

  age.identityPaths = [
    "${config.xdg.configHome}/age/keys.txt"
  ];

  age.secrets.ssh-personal = {
    file = ../secrets/ssh-personal.age;
    path = "${config.home.homeDirectory}/.ssh/id_personal";
  };

}
