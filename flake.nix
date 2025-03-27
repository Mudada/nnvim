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
    nv-dark-notify = {
      url = "github:Mudada/dark-notify";
    };
    treesitter-nu-grammar = {
      url = "github:nushell/tree-sitter-nu";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      username = "tangui";
    in {
      # defaultPackage.${system} = home-manager.defaultPackage.${system};
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
	  ./home.nix { inherit username; }
	  inputs.nixvim.homeManagerModules.nixvim
	];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
