# Plan: Host rmfakecloud on marcus for reMarkable Pro

## Context

The goal is to self-host [rmfakecloud](https://github.com/ddvk/rmfakecloud) on the NixOS server (marcus) so the reMarkable Pro can sync to it instead of reMarkable's official cloud. Since WireGuard can't be installed on the reMarkable Pro (no tun support, no opkg), we secure the connection with HTTPS (Let's Encrypt) + rmfakecloud's built-in JWT device authentication.

rmfakecloud is already packaged in nixpkgs as `services.rmfakecloud`.

## Implementation

### 1. Create `modules/rmfakecloud/default.nix`

New NixOS module that configures:

- **`services.rmfakecloud`**: enable the service on port 3000, set `storageUrl` to `https://<your-domain>`
- **`services.nginx`**: reverse proxy on port 443 with Let's Encrypt HTTPS, proxying to localhost:3000
- **Firewall**: open TCP 443 (HTTPS)
- **agenix secret**: for the `JWT_SECRET_KEY` environment variable (passed via `environmentFile`)

```nix
{ config, pkgs, ... }:
{
  services.rmfakecloud = {
    enable = true;
    storageUrl = "https://<domain>";
    environmentFile = config.age.secrets.rmfakecloud-env.path;
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    virtualHosts."<domain>" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3000";
        proxyWebsockets = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "<email>";
  };

  networking.firewall.allowedTCPPorts = [ 443 ];
}
```

### 2. Create agenix secret for JWT key

- Generate JWT secret: `openssl rand -base64 48`
- Create `secrets/rmfakecloud-env.age` containing `JWT_SECRET_KEY=<generated-key>`
- Add to `secrets/secrets.nix` with marcus + mudada public keys
- Reference in module via `config.age.secrets.rmfakecloud-env.path`

Note: this secret needs to use the **system-level** agenix module (not home-manager), since `services.rmfakecloud` runs as a system service. The system-level agenix module needs to be added to the NixOS config in `flake.nix`.

### 3. Import in `flake.nix`

Add `./modules/rmfakecloud` to the `buildNixosConfiguration` modules list and add `agenix.nixosModules.default` for system-level secret decryption.

### 4. Update `modules/README.md`

Add rmfakecloud to the modules table.

### 5. Create `modules/rmfakecloud/README.md`

Document:
- How the module works
- How to configure the reMarkable Pro (manual steps on device):
  1. SSH into tablet: `ssh root@10.11.99.1`
  2. Edit `/etc/hosts` to redirect remarkable cloud domains to server IP
  3. Install the Let's Encrypt CA (already trusted by default, so this may not be needed)
  4. Register device via rmfakecloud web UI (one-time code)
- Warning: tablet firmware updates may reset `/etc/hosts`

## Files to modify/create

| File | Action |
|------|--------|
| `modules/rmfakecloud/default.nix` | Create - main module |
| `modules/rmfakecloud/README.md` | Create - documentation |
| `secrets/secrets.nix` | Edit - add rmfakecloud-env secret |
| `secrets/rmfakecloud-env.age` | Create - encrypted JWT secret |
| `flake.nix` | Edit - add module import + agenix nixos module |
| `modules/README.md` | Edit - add to table |

## Verification

1. Rebuild marcus: `sudo nixos-rebuild switch --flake /etc/nix-darwin#marcus`
2. Check services: `systemctl status rmfakecloud` and `systemctl status nginx`
3. Verify HTTPS: `curl https://<domain>` should respond
4. Register reMarkable via web UI
5. Test sync from the tablet
