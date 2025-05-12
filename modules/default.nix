{lib, config, username, ... }:
{
  imports = [
    ./system
    ./home { inherit username; }
    ./nvim
  ];
}
