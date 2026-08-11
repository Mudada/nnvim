{ pkgs, ... }:
let
  pigeons = pkgs.callPackage ../../packages/pigeons.nix { };
in
{
  environment.systemPackages = [ pigeons ];

  systemd.services.pigeons = {
    description = "pigeons roost";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment.RUST_LOG = "info";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pigeons}/bin/pigeons roost";
      Restart = "on-failure";
      RestartSec = "3s";
      WorkingDirectory = "/root";
    };
  };
}
