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

    disko = {
      url = "github:nix-community/disko";
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

    yk-attest-verify = {
      url = "github:joemiller/homebrew-taps";
      flake = false;
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "nix-darwin";
      inputs.home-manager.follows = "home-manager";
    };

    # for spotlight
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs@{
      nix-darwin,
      nixpkgs,
      nur,
      home-manager,
      nix-homebrew,
      mac-app-util,
      agenix,
      disko,
      ...
    }:
    let
      overlays = [
        nur.overlays.default
      ]
      ++ [
        (final: prev: {
          clever-tools = prev.clever-tools.overrideAttrs (old: {
            npmFlags = [ "--ignore-scripts" ];
          });
        })
      ];

      mkDarwin = host: nix-darwin.lib.darwinSystem {
        modules = [
          { nixpkgs.overlays = overlays; }
          mac-app-util.darwinModules.default
          inputs.nixvim.nixDarwinModules.nixvim
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          host
        ];
        specialArgs = { inherit inputs mac-app-util; };
      };

      mkNixos = host: nixpkgs.lib.nixosSystem {
        modules = [
          { nixpkgs.overlays = overlays; }
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          inputs.nixvim.nixosModules.nixvim
          host
        ];
        specialArgs = { inherit inputs; };
      };
    in
    {
      nixosConfigurations.marcus = mkNixos ./hosts/marcus;
      nixosConfigurations.arthur = mkNixos ./hosts/arthur;
      darwinConfigurations.mudada = mkDarwin ./hosts/mudada;
      darwinConfigurations.tangui = mkDarwin ./hosts/tangui;

      packages = nixpkgs.lib.genAttrs
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
        (system: {
          pigeons = nixpkgs.legacyPackages.${system}.callPackage ./packages/pigeons.nix { };
        });
    };
}
