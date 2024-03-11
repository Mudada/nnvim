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

    # neovim plugins
    nv-haskell-tools = {
      url = "github:mrcjkb/haskell-tools.nvim";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      defaultPackage.${system} = home-manager.defaultPackage.${system};
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
