{
  inputs,
  ...
}:
let
  username = "marcus";
  email = "github@t1fr.fr";
  user = { inherit username email; };
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./system.nix
    ../../modules/server
    ../../modules/nvim
    ../../modules/wireguard/client.nix
    ../../modules/jellyfin
    ../../modules/immich
    ../../modules/pigeons/server.nix
  ];

  _module.args = { inherit username email user; };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.${username} = ../../home/server.nix;
  home-manager.extraSpecialArgs = {
    sys = "x86_64-linux";
    inherit
      inputs
      username
      email
      user
      ;
  };
}
