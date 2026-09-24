{ config, ... }:
{
  # NC_AUTH_JWT_SECRET + NC_DB (the latter embeds the same password set on the postgres
  # role below). Read by podman as root via --env-file, so agenix's default root:root
  # ownership is fine here.
  age.secrets.nocodb-env.file = ../../secrets/nocodb-env.age;
  # Plaintext DB password, same value as in nocodb-env's NC_DB — kept as its own secret
  # so the ALTER ROLE oneshot below doesn't need to parse it out of the combined file.
  age.secrets.nocodb-db-password.file = ../../secrets/nocodb-db-password.age;

  # Shares Outline's postgres cluster (modules/outline) rather than running a second one.
  services.postgresql = {
    enableTCPIP = true; # default pg_hba already has `host all all 127.0.0.1/32 md5`
    ensureDatabases = [ "nocodb" ];
    ensureUsers = [
      {
        name = "nocodb";
        ensureDBOwnership = true;
      }
    ];
  };

  # ensureUsers has no password option (it would mean an unencrypted hash sitting in the
  # Nix store) — set the real password imperatively instead, from the same agenix secret
  # NC_DB is built from. Idempotent, so safe to rerun on every activation/boot.
  systemd.services.nocodb-db-password = {
    # ensureUsers/ensureDatabases run in the separate postgresql-setup.service, not as
    # part of postgresql.service itself — the "nocodb" role doesn't exist until that unit
    # (RemainAfterExit) has completed, hence depending on this one instead.
    after = [ "postgresql-setup.service" ];
    requires = [ "postgresql-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      LoadCredential = "password:${config.age.secrets.nocodb-db-password.path}";
    };
    # `script` (unlike serviceConfig.ExecStart, which execs argv directly, not through a
    # shell) actually runs this via bash — needed for $(...) and $CREDENTIALS_DIRECTORY to
    # be expanded at all rather than passed to psql as a literal string.
    #
    # psql's `:'var'` interpolation only works in interactive mode or `-f` script files,
    # never with `-c` (the server must receive a fully-formed, psql-feature-free command —
    # see https://www.postgresql.org/docs/current/app-psql.html and the psql bug tracker,
    # BUG #18061) — so this has to be plain shell substitution into the SQL string. Safe
    # here specifically because the password is generated as pure hex (openssl rand -hex),
    # never containing a quote or backslash that could break out of the literal.
    script = ''
      password=$(cat "$CREDENTIALS_DIRECTORY/password")
      ${config.services.postgresql.package}/bin/psql -v ON_ERROR_STOP=1 -c "ALTER ROLE nocodb WITH PASSWORD '$password'"
    '';
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.nocodb = {
      # nocodb/nocodb:2026.09.0, pinned by multi-arch index digest. To bump:
      #   nix run nixpkgs#skopeo -- inspect --raw docker://nocodb/nocodb:<tag> | shasum -a 256
      # Must be fully qualified (docker.io/...) — unlike Docker, podman won't guess a
      # registry for a short name unless unqualified-search-registries is configured.
      image = "docker.io/nocodb/nocodb@sha256:4ccfc5114506b1725ffc63be56445fc6fe453a6e6d5cb56eb5f88f0540d4e56e";
      autoStart = true;

      # Host networking so the container can reach postgres on 127.0.0.1:5432 — no other
      # namespace-crossing option exists without also containerizing postgres itself.
      # This also sidesteps the earlier published-port firewall-bypass problem entirely:
      # in host mode there's no DNAT, so the ordinary INPUT-chain firewall applies exactly
      # like it does to any native service (not in allowedTCPPorts => wg0-only, as before).
      extraOptions = [ "--network=host" ];
      # PORT must be overridden: host-network mode means the container's bind port IS the
      # host's port, and 8080 (the image default) already belongs to filebrowser (see
      # hosts/marcus/system.nix).
      environment = {
        NC_DISABLE_TELE = "true";
        PORT = "8085";
      };

      volumes = [ "/var/lib/nocodb:/usr/app/data" ];
      environmentFiles = [ config.age.secrets.nocodb-env.path ];
    };
  };

  systemd.services.podman-nocodb = {
    after = [ "nocodb-db-password.service" ];
    requires = [ "nocodb-db-password.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/nocodb 0750 root root -"
  ];
}
