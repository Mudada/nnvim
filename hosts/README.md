# Hosts

| Host    | Type        | Platform       | User   | Role                                      |
|---------|-------------|----------------|--------|-------------------------------------------|
| mudada  | Darwin      | aarch64-darwin | mudada | Main macOS workstation                    |
| tangui  | Darwin      | aarch64-darwin | tangui | Secondary macOS machine                   |
| marcus  | NixOS Linux | x86_64-linux   | marcus | Home server (Jellyfin, WireGuard client)  |
| arthur  | NixOS Linux | x86_64-linux   | marcus | VPS WireGuard hub (jump server)           |

## WireGuard topology

```
  mac / iphone
      │
      │ (connect to arthur)
      ▼
  arthur VPS  ──────────  marcus (home server)
  10.100.0.1             10.100.0.4
  (hub)                  (spoke, PersistentKeepalive)

VPN subnet: 10.100.0.0/24
  arthur:  10.100.0.1
  mac:     10.100.0.2
  iphone:  10.100.0.3
  marcus:  10.100.0.4
```

Marcus has no fixed home IP — it dials out to arthur with PersistentKeepalive=25.
All peers reach marcus (and its Jellyfin at :8096) through arthur.
