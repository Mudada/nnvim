{
  pkgs,
  inputs,
  username,
  user,
  ...
}:
let
  taps = {
    "homebrew/homebrew-core" = inputs.homebrew-core;
    "homebrew/homebrew-cask" = inputs.homebrew-cask;
    "nikitabobko/homebrew-AeroSpace" = inputs.nikitabobko-aerospace;
    "joemiller/homebrew-taps" = inputs.yk-attest-verify;
  };
in
{

  environment.systemPackages = [
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
  networking = {
    knownNetworkServices = [
      "Wi-Fi"
      "Thunderbolt Bridge"
    ];
    dns = [
      "86.54.11.13"
      "86.54.11.213"
      "2a13:1001::86:54:11:13"
      "2a13:1001::86:54:11:213"
    ];
  };

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  system.defaults.dock.persistent-apps = [ ];
  system.defaults.dock.tilesize = 32;

  security.pam.services.sudo_local.touchIdAuth = true;

  # nix-homebrew pins taps as nix store symlinks with no git remote; the patched brew used during
  # activation has HOMEBREW_REQUIRE_TAP_TRUST=true by default and rejects them as "untrusted".
  # Pinning via flake inputs already provides the security guarantee that tap trust would give.
  environment.variables.HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
    taps = taps;
    mutableTaps = true; # must for cc-clamav
  };

  # Fix Stremio codesigning after homebrew upgrade
  system.activationScripts.postActivation.text = ''
    if [ -d /Applications/Stremio.app ]; then
      xattr -cr /Applications/Stremio.app
      find /Applications/Stremio.app -name "._*" -delete
      find /Applications/Stremio.app -name ".DS_Store" -delete
      codesign --force --deep --sign - /Applications/Stremio.app
    fi
  '';

  homebrew = {
    enable = true;
    taps = builtins.attrNames taps;

    casks = [
      # Required via casks because 1password doesnt work properly if not in /Applications
      "1password"
      "nikitabobko/tap/aerospace" # TODO: fix this so i can install it with mutableTaps: false
      "telegram"
      "proton-mail"
      "proton-drive"
      "proton-pass"
      "protonvpn"
    ]
    ++ (user.brew-casks or [ ]);

    brews = [ "yk-attest-verify" ];

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
