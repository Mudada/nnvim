# WireGuard

Hub-and-spoke topology. The arthur VPS is the hub; all other devices are spokes.
Marcus lives behind a residence NAT with no fixed IP — it dials out with PersistentKeepalive.

## Files

| File        | Purpose                                          |
|-------------|--------------------------------------------------|
| server.nix  | Relay VPS: WireGuard server, peers all devices   |
| client.nix  | Marcus: WireGuard client, connects to arthur      |

## Peer IPs

| Device  | VPN IP      | Public key file        |
|---------|-------------|------------------------|
| arthur   | 10.100.0.1  | arthur-public.key       |
| mac     | 10.100.0.2  | mac-public.key         |
| iphone  | 10.100.0.3  | iphone-public.key      |
| marcus  | 10.100.0.4  | marcus-public.key      |

## Initial key setup

### On marcus (client)
```sh
wg genkey | sudo tee /etc/wireguard/marcus-private.key | wg pubkey | sudo tee /etc/wireguard/marcus-public.key
# Copy the public key output into modules/wireguard/server.nix → marcus peer publicKey
```

### On arthur (server)
```sh
wg genkey | sudo tee /etc/wireguard/arthur-private.key | wg pubkey | sudo tee /etc/wireguard/arthur-public.key
# Copy the public key output into modules/wireguard/client.nix → arthur peer publicKey
```

## Updating mac/iphone client configs

Mac and iPhone WireGuard configs only need one change: update the `Endpoint` from
marcus's old home IP to the arthur VPS's public IP. Everything else (keys, IPs) stays the same.

```ini
[Peer]
PublicKey = <arthur public key>
Endpoint = <arthur-public-ip>:51820
AllowedIPs = 10.100.0.0/24
```

## Adding a new peer

1. Generate keypair on the device.
2. Add a peer block in `server.nix` with the next available IP (10.100.0.5/32, etc.).
3. Configure the device to connect to the arthur (Endpoint = arthur-ip:51820, AllowedIPs = 10.100.0.0/24).
4. Rebuild arthur: `nixos-rebuild switch --flake .#arthur`.
