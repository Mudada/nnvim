# WireGuard Module

This module configures a WireGuard VPN server on the NixOS host (marcus). It is imported only in `buildNixosConfiguration` in `flake.nix`.

## How it works

The server runs a `wg0` interface on the `10.100.0.0/24` subnet:

- **Server IP**: `10.100.0.1/24`
- **Listen port**: `51820` (UDP)
- **Private key**: stored at `/etc/wireguard/server-private.key` on the server (not managed by nix -- placed manually)
- **NAT**: enabled, forwarding traffic from `wg0` to `eth0`

Firewall rules allow UDP 51820 (WireGuard) and TCP 22 (SSH).

## Current peers

| Peer   | Public key file       | Tunnel IP    |
|--------|-----------------------|--------------|
| mac    | `mac-public.key`      | 10.100.0.2   |
| iphone | `iphone-public.key`   | 10.100.0.3   |

## Adding a peer

1. Generate a keypair on the new device:

   ```sh
   wg genkey | tee private.key | wg pubkey > public.key
   ```

2. Save the public key in this directory (e.g. `tablet-public.key`).

3. Add a new entry to the `peers` list in `default.nix`, picking the next available IP:

   ```nix
   {
     publicKey = "<contents of public.key>";
     allowedIPs = [ "10.100.0.4/32" ];
   }
   ```

4. On the new device, create/edit `/etc/wireguard/wg0.conf`:

   ```ini
   [Interface]
   Address = 10.100.0.4/24
   PrivateKey = <contents of private.key>

   [Peer]
   PublicKey = <contents of server-public.key>
   Endpoint = <server-public-ip>:51820
   AllowedIPs = 0.0.0.0/0  # route all traffic, or 10.100.0.0/24 for VPN only
   ```

   Then bring it up with `wg-quick up wg0`.

5. Rebuild: `sudo nixos-rebuild switch --flake /etc/nix-darwin`

## Removing a peer

1. Delete the peer entry from the `peers` list in `default.nix`.
2. Optionally remove the corresponding public key file.
3. Rebuild: `sudo nixos-rebuild switch --flake /etc/nix-darwin`
