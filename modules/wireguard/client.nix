# WireGuard client — marcus connects outbound to the arthur VPS hub.
# No inbound port needed; PersistentKeepalive keeps the tunnel alive through NAT.
#
# Before first deploy, generate a keypair on marcus:
#   wg genkey | sudo tee /etc/wireguard/marcus-private.key | wg pubkey
# Copy the printed public key into hosts/arthur/default.nix as marcus's peer publicKey.
{
  ...
}:
{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.4/24" ];

    privateKeyFile = "/etc/wireguard/marcus-private.key";

    peers = [
      {
        # Relay VPS — the WireGuard hub
        # TODO: replace with the arthur's actual WireGuard public key
        publicKey = "2efEBDlOz8bwtPqTowl8PdiV5J1If15wzMx7Vn/Dg3Y=";
        # TODO: replace with the arthur VPS's public IP address
        endpoint = "51.159.70.22:51820";
        allowedIPs = [ "10.100.0.0/24" ];
        # Keepalive punches through the residence NAT so the arthur can always reach marcus
        persistentKeepalive = 25;
      }
    ];
  };

}
