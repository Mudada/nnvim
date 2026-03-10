{
  inputs,
  mac-app-util,
  ...
}:
let
  username = "tangui";
  email = "mael.nicolas@clever-cloud.com";
  user = { inherit username email; };
in
{
  imports = [
    ../../modules/darwin
    ../../modules/nvim
  ];

  _module.args = { inherit username email user; };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.${username} = ../../home;
  home-manager.extraSpecialArgs = {
    sys = "aarch64-darwin";
    inherit inputs username email user;
  };
  home-manager.sharedModules = [
    mac-app-util.homeManagerModules.default
  ];
}
