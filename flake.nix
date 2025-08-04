{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
	url = "github:nix-darwin/nix-darwin/master";
    	inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nv-dark-notify = {
      url = "github:Mudada/dark-notify";
    };

  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, ... }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Use determinate system nix distribution
      nix.enable = false;

      users.users."mudada" = {
	      home = "/Users/mudada";
      };
    };
    sys = "aarch64-darwin";
    username = "mudada"; 
    pkgs = nixpkgs.legacyPackages.${sys};
    nixvim = inputs.nixvim.homeModules.nixvim;
    home-manager = inputs.home-manager.darwinModules; 
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."MacBook-Air-de-mudada" = nix-darwin.lib.darwinSystem {
      modules = [ 
	configuration 
	home-manager.home-manager {
	  home-manager.useGlobalPkgs = true;
	  home-manager.useUserPackages = true;
	  home-manager.users.${username} = import ./home.nix {
	    inherit inputs;
	    username = "mudada";
	    sys = "aarch64-darwin";
	  };
	  home-manager.extraSpecialArgs = { inherit inputs username sys; };
	}
      ];
    };
  };
}
