{ pkgs, inputs, username, ... }:
{
  environment.systemPackages =
    [ 
      pkgs.vim
    ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Use determinate system nix distribution
  nix.enable = false;

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
    allowUnsupportedSystem = false;
  };

  users.users."${username}" = {
    home = "/Users/${username}";
    shell = pkgs.nushell;
  };

  system.primaryUser = "mudada";
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain = {
      KeyRepeat = 1;
      InitialKeyRepeat = 10;
      AppleInterfaceStyleSwitchesAutomatically = true;
    };
  };
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  system.defaults.dock.persistent-apps = []; 
  system.defaults.dock.tilesize = 32;
}
