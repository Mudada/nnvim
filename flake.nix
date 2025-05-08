{
  description = "Home Manager configuration of gobmeboul";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "mudada";
    in {
      nixosConfigurations.${username} = nixpkgs.lib.nixosSystem {
	modules = [ 
	  home-manager.nixosModules.home-manager
	  ./modules
	];
	specialArgs = { inherit username; };
      };
    };
}
