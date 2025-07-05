{ lib, config, ... }:

{
  options = {
    steam = {
      enable = lib.mkEnableOption "Steam";
    };
  };

  config = lib.mkIf (config.steam.enable) {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };
}
