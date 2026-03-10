{
  inputs,
  ...
}:
let
  username = "mudada";
  email = "mael.nicolas77@gmail.com";
  user = { inherit username email; };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/server
    ../../modules/niri
    ../../modules/nvim
    ../../modules/steam.nix
    ../../modules/linux
    ../../modules/wireguard
  ];

  _module.args = { inherit username email user; };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.${username} = ../../home;
  home-manager.extraSpecialArgs = {
    sys = "x86_64-linux";
    inherit inputs username email user;
  };
}
