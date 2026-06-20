{ config, pkgs, ... }:
let
  runnerConfig = pkgs.writeText "runner-config.yml" ''
    log:
      level: info
      job_level: info

    runner:
      file: .runner
      capacity: 2
      timeout: 3h
      shutdown_timeout: 3h
      insecure: false
      fetch_timeout: 30s
      fetch_interval: 2s
      report_interval: 1s
      labels: []

    cache:
      enabled: true
      port: 0

    container:
      network: ""
      docker_host: "unix:///run/podman/podman.sock"
      force_pull: false
      force_rebuild: false

    host:
      workdir_parent:

    server:
      connections:
        codeberg:
          url: https://codeberg.org/
          uuid: 4f2a7564-baa5-4f4e-ab4d-25edf40578bd
          # systemd LoadCredential below writes the token into a per-unit
          # tmpfs; $CREDENTIALS_DIRECTORY is set at runtime by systemd.
          token_url: file:$CREDENTIALS_DIRECTORY/forgejo-runner-token
          labels:
            - self-hosted
  '';
in
{
  age.secrets.forgejo-runner-token = {
    file = ../../secrets/forgejo-runner-token.age;
    mode = "0400";
  };

  # Podman as a daemon-free Docker-API-compatible runtime.
  # The docker socket compat layer lets forgejo-runner speak the Docker
  # API while Podman handles the actual container lifecycle.
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
    after = [
      "network-online.target"
      "podman.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "forgejo-runner";
      Group = "forgejo-runner";
      WorkingDirectory = "/var/lib/forgejo-runner";
      StateDirectory = "forgejo-runner";
      StateDirectoryMode = "0750";
      # Token is loaded from the agenix-decrypted path into a
      # process-local credential tmpfs; never enters the nix store.
      LoadCredential = [ "forgejo-runner-token:${config.age.secrets.forgejo-runner-token.path}" ];
      Environment = [ "DOCKER_HOST=unix:///run/podman/podman.sock" ];
      ExecStart = "${pkgs.forgejo-runner}/bin/forgejo-runner daemon -c ${runnerConfig}";
      ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
      Restart = "on-failure";
      RestartSec = 10;
      TimeoutSec = 0;
    };
  };
}
