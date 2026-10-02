{ config, pkgs, ... }:
let
  # Public hostname (nginx on arthur, see hosts/arthur/default.nix).
  host = "proute.pisse.cloud";

  # Static overrides AFFiNE reads from ~/.affine/config/config.json, shape { module: { option: value } }.
  # newAccountShareActionDelay (default 24h) stops accounts younger than that from creating
  # invite/share *links*; 0 lifts it so a fresh owner can invite a second account straight away.
  # Email invites stay blocked for 24h regardless: that quota is hard-coded in the native
  # runtime. Remove this once it's no longer needed to get the default protection back.
  configJson = pkgs.writeText "affine-config.json" (builtins.toJSON {
    auth.newAccountShareActionDelay = 0;
  });
in
{
  # POSTGRES_PASSWORD (for the postgres container) and DATABASE_URL (for affine) — same
  # password in both. Read by podman as root via --env-file, so root:root is fine.
  age.secrets.affine-env.file = ../../secrets/affine-env.age;

  # Native redis (AFFiNE reads REDIS_SERVER_HOST/PORT). Loopback only; immich already
  # runs its own on a unix socket, so this one needs a distinct TCP port.
  services.redis.servers.affine = {
    enable = true;
    bind = "127.0.0.1";
    port = 6380;
  };

  virtualisation.oci-containers = {
    backend = "podman";

    # AFFiNE hard-requires pgvector (its migrations CREATE EXTENSION vector and abort if
    # it's missing), so it gets upstream's own pgvector image instead of the shared native
    # cluster that immich depends on — keeps extension/restart changes off that cluster.
    containers.affine-postgres = {
      # pgvector/pgvector:pg16, pinned by index digest. To bump:
      #   nix run nixpkgs#skopeo -- inspect --raw docker://pgvector/pgvector:pg16 | shasum -a 256
      image = "docker.io/pgvector/pgvector@sha256:7b822b0aac60967beb1ea5e576b8602c94c300a157d187f385ae3e0da199b90a";
      autoStart = true;
      # Host networking, as for the other containers here: no published-port DNAT around
      # the firewall, and 5433 listens on loopback only (5432 is the native cluster's).
      extraOptions = [ "--network=host" ];
      cmd = [
        "postgres"
        "-c" "listen_addresses=127.0.0.1"
        "-c" "port=5433"
      ];
      environment = {
        POSTGRES_USER = "affine";
        POSTGRES_DB = "affine";
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };
      environmentFiles = [ config.age.secrets.affine-env.path ];
      volumes = [ "/var/lib/affine/postgres:/var/lib/postgresql/data" ];
    };

    containers.affine = {
      # ghcr.io/toeverything/affine 0.27.4 (== :stable at pin time), by index digest.
      # Pre-1.0 software: upstream warns of breaking changes between releases, so bump
      # deliberately. Stable on purpose: the official workspace MCP only allows *write* on the
      # canary channel (AFFINE_ENV=dev), so writes go through the community MCP server instead
      # (packages/affine-mcp-server.nix), which logs in as a normal user and needs no flag.
      # A database that has run canary can't be pointed back at stable — wipe it first. To bump:
      #   nix run nixpkgs#skopeo -- inspect --raw docker://ghcr.io/toeverything/affine:<tag> | shasum -a 256
      image = "ghcr.io/toeverything/affine@sha256:b649f5ce2384ffdf13c23bccf81d759e15973d59d0b0058af65d895a84373099";
      autoStart = true;
      dependsOn = [ "affine-postgres" ];
      extraOptions = [ "--network=host" ];
      # Upstream's compose runs the migration as a separate one-shot container; doing it in
      # front of the server here is equivalent (the script is idempotent) and means a single
      # unit to supervise. exec so node, not sh, receives SIGTERM from systemd.
      cmd = [
        "sh"
        "-c"
        "node ./scripts/self-host-predeploy.js && exec node ./dist/main.js"
      ];
      environment = {
        REDIS_SERVER_HOST = "127.0.0.1";
        REDIS_SERVER_PORT = "6380";
        # Needs a separate Manticore service; off, as in upstream's default compose.
        AFFINE_INDEXER_ENABLED = "false";
        # Must match the public URL exactly or websocket collaboration fails.
        AFFINE_SERVER_EXTERNAL_URL = "https://${host}";
        AFFINE_SERVER_HOST = host;
        AFFINE_SERVER_HTTPS = "true";
      };
      environmentFiles = [ config.age.secrets.affine-env.path ];
      volumes = [
        "/var/lib/affine/storage:/root/.affine/storage"
        "/var/lib/affine/config:/root/.affine/config"
      ];
    };
  };

  systemd.services.podman-affine = {
    after = [ "redis-affine.service" ];
    requires = [ "redis-affine.service" ];
    # dependsOn only orders container *start*; a fresh postgres still needs a few seconds
    # (first run: initdb) before it accepts connections, and the migration would otherwise
    # crash-loop into the start limit — the failure mode NocoDB hit.
    preStart = ''
      # A real file, not a symlink: the container can't follow a link into /nix/store.
      ${pkgs.coreutils}/bin/install -m 0644 ${configJson} /var/lib/affine/config/config.json
      ${pkgs.coreutils}/bin/timeout 120 ${pkgs.bash}/bin/bash -c \
        'until (echo > /dev/tcp/127.0.0.1/5433) 2>/dev/null; do sleep 1; done'
    '';
  };

  # Podman, unlike Docker, won't create missing bind-mount sources. The postgres
  # entrypoint chowns its data dir to the in-container postgres user itself.
  systemd.tmpfiles.rules = [
    "d /var/lib/affine          0755 root root -"
    "d /var/lib/affine/postgres 0700 root root -"
    "d /var/lib/affine/storage  0750 root root -"
    "d /var/lib/affine/config   0750 root root -"
  ];

  # No firewall option involved: host-networked, so 3010 is covered by the ordinary
  # INPUT-chain rules — never in allowedTCPPorts, reachable only via wg0 (arthur's nginx).
}
