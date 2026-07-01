# Forgejo Actions runner against Codeberg.
# Token must be dropped by hand at /etc/forgejo-runner/runner-token (root:root 0400) before first deploy.
{ pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
  };

  users.users.forgejo-runner = {
    isSystemUser = true;
    group = "forgejo-runner";
    extraGroups = [ "podman" ];
    home = "/var/lib/forgejo-runner";
    createHome = true;
  };
  users.groups.forgejo-runner = { };

  systemd.services.forgejo-runner = {
    description = "Forgejo Actions Runner";
    documentation = [ "https://forgejo.org/docs/latest/admin/actions/" ];
    after = [ "network-online.target" "podman.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "forgejo-runner";
      Group = "forgejo-runner";
      WorkingDirectory = "/var/lib/forgejo-runner";
      StateDirectory = "forgejo-runner";
      StateDirectoryMode = "0750";
      LoadCredential = [ "runner-token:/etc/forgejo-runner/runner-token" ];
      Environment = [ "DOCKER_HOST=unix:///run/podman/podman.sock" ];
      ExecStart = "${pkgs.forgejo-runner}/bin/forgejo-runner daemon -c ${./config.yml}";
      ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
      Restart = "on-failure";
      RestartSec = 10;
      TimeoutSec = 0;
    };
  };
}
