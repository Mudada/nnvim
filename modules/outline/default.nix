{ config, ... }:
{
  # agenix secrets default to root:root 0400 — outline's own script (running as the
  # unprivileged `outline` user, not root) reads these files itself via `head`, so they
  # need to be readable by that user specifically.
  age.secrets.outline-secret-key = {
    file = ../../secrets/outline-secret-key.age;
    owner = "outline";
  };
  age.secrets.outline-oidc-client-secret = {
    file = ../../secrets/outline-oidc-client-secret.age;
    owner = "outline";
  };

  services.outline = {
    enable = true;
    publicUrl = "https://proute.pisse.cloud";
    secretKeyFile = config.age.secrets.outline-secret-key.path;
    # utilsSecretFile left at its default (/var/lib/outline/utils_secret) — Outline
    # generates and persists it itself on first run if the file doesn't exist yet.

    # databaseUrl/redisUrl left at their "local" default: the module then declares
    # services.postgresql and services.redis.servers.outline itself, wired up with the
    # right ensureUsers/ensureDatabases and systemd ordering — nothing to configure here.

    storage.storageType = "local";

    oidcAuthentication = {
      clientId = "7d4824a8-b6fc-4714-9174-26cd1e7effbd";
      clientSecretFile = config.age.secrets.outline-oidc-client-secret.path;
      authUrl = "https://basquettes.pisse.cloud/authorize";
      tokenUrl = "https://basquettes.pisse.cloud/api/oidc/token";
      userinfoUrl = "https://basquettes.pisse.cloud/api/oidc/userinfo";
      displayName = "Pocket ID";
      scopes = [ "openid" "profile" "email" ];
    };
  };

  # No openFirewall option (same pattern as jellyfin/immich/pocket-id) — the port is never
  # added to allowedTCPPorts, reachable only via wg0. Public access comes from arthur's
  # nginx proxying to this over the tunnel.
}
