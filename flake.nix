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
    nv-dark-notify = {
      url = "github:Mudada/dark-notify";
    };
    nvim-nu = {
      url = "github:LhKipp/nvim-nu";
      flake = false;
    };
    nv-nvim-metals = {
      url = "github:scalameta/nvim-metals";
      flake = false;
    };
    treesitter-nu-grammar = {
      url = "github:nushell/tree-sitter-nu";
      flake = false;
    };
    nix-metals = {
      url = "github:ghostbuster91/nix-metals/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      username = if (builtins.pathExists ./username.nix) then (import ./username.nix) else "You need to declare a username.nix file with your username.";
    in {
      defaultPackage.${system} = home-manager.defaultPackage.${system};
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
