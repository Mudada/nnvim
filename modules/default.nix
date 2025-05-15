{lib, config, username, ... }:
{
  imports = [
    ./system
    ./home { inherit username; }
    ./nvim
    ./niri { inherit username; }
    ./steam.nix
  ];

  config = {
    steam.enable = true;
  };
}
