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
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."gobmeboul" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
	  ./home.nix 
	  inputs.nixvim.homeManagerModules.nixvim
	];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
