{ pkgs, inputs, username, user, ... }:
let taps = {
  "homebrew/homebrew-core" 		= inputs.homebrew-core;
  "homebrew/homebrew-cask" 		= inputs.homebrew-cask;
  "nikitabobko/homebrew-AeroSpace"  	= inputs.nikitabobko-aerospace;
};
in
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

  system.primaryUser = username;
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain = {
      KeyRepeat = 1;
      InitialKeyRepeat = 10;
      AppleInterfaceStyleSwitchesAutomatically = true;
      "com.apple.swipescrolldirection" = true;
    };
  };
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  system.defaults.dock.persistent-apps = [];
  system.defaults.dock.tilesize = 32;

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
    taps = taps;
  };

  homebrew = {
    enable = true;
    taps = builtins.attrNames taps;

    casks = [
      # Required via casks because 1password doesnt work properly if not in /Applications
      "1password"
      "nikitabobko/tap/aerospace" # TODO: fix this so i can install it with mutableTaps: false
    ] ++ (user.brew-casks or []);

    #ensures only declarative brew apps are installed.
    #apps installed imperatively are deleted
    onActivation = {
      cleanup = "zap";
      #ensures auto update and upgrade on darwin rebuild
      autoUpdate = true;
      upgrade = true;
    };
  };

}
