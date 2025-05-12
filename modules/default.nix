{lib, config, username, ... }:
{
  imports = [
    ./system
    ./home { inherit username; }
    ./nvim
    ./niri { inherit username; }
  ];
}
