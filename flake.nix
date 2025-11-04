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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    nikitabobko-aerospace = {
      url = "github:nikitabobko/AeroSpace";
      flake = false;
    };

    # for spotlight
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ nix-darwin, nixpkgs, nur, home-manager, nix-homebrew, mac-app-util, ... }:
    let
      sys = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${sys};
      overlays = [
	nur.overlays.default
      ];
      listToPackages = {ps}: map (p: pkgs."${p}") ps;
      buildNixDdarwinConfiguration = {username, email, ...}@user:
	nix-darwin.lib.darwinSystem {
	  modules = [
	    { nixpkgs.overlays = overlays; }
	    mac-app-util.darwinModules.default
	    inputs.nixvim.nixDarwinModules.nixvim
	    nix-homebrew.darwinModules.nix-homebrew
	    ./modules/darwin
	    ./modules/nvim
	    home-manager.darwinModules.home-manager
	    {
	      home-manager.useGlobalPkgs = true;
	      home-manager.useUserPackages = true;
	      home-manager.backupFileExtension = "backup";
	      home-manager.users.${username} = ./home;
	      home-manager.extraSpecialArgs = { inherit inputs username sys email user; };
	      home-manager.sharedModules = [
		mac-app-util.homeManagerModules.default
	      ];
	    }
	  ];
	  specialArgs = { inherit inputs username email user; };
	};
    in
      {
      darwinConfigurations = {
	mudada = let
	  username = "mudada";
	  email = "mael.nicolas77@gmail.com";
		brew-casks = ["stremio"];
	in buildNixDdarwinConfiguration {inherit username email brew-casks;};
	tangui = let
	  username = "tangui";
	  email = "mael.nicolas@clever-cloud.com";
	in buildNixDdarwinConfiguration {inherit username email;};
      };
    };
}
