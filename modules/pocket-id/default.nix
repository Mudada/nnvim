{ config, ... }:
{
  age.secrets.pocket-id-encryption-key.file = ../../secrets/pocket-id-encryption-key.age;

  services.pocket-id = {
    enable = true;
    credentials.ENCRYPTION_KEY = config.age.secrets.pocket-id-encryption-key.path;
    settings = {
      APP_URL = "https://basquettes.pisse.cloud";
      # nginx on arthur terminates TLS and proxies here over the wg0 tunnel.
      TRUST_PROXY = true;
    };
  };

  # No openFirewall option here either (same as jellyfin/immich/code-server) — the port is
  # never added to allowedTCPPorts, so it's only reachable via wg0 (a trustedInterface, see
  # modules/server). Public access comes from arthur's nginx proxying to this over the tunnel.
}
