# WireGuard hub — runs on the arthur VPS.
# All peers (marcus, mac, iphone) connect here; the arthur forwards traffic between them.
#
# Before first deploy, generate a keypair on the arthur:
#   wg genkey | sudo tee /etc/wireguard/arthur-private.key | wg pubkey
# Copy the printed public key into client.nix (and peer configs on mac/iphone) as the arthur's publicKey.
{
  ...
}:
{
  # Forward packets between WireGuard peers (hub-and-spoke routing)
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ];
    allowedTCPPorts = [ 22 ];
    # Allow VPN peers to reach each other through this hub (FORWARD chain)
    extraCommands = ''
      iptables -A FORWARD -i wg0 -j ACCEPT
      iptables -A FORWARD -o wg0 -j ACCEPT
    '';
    extraStopCommands = ''
      iptables -D FORWARD -i wg0 -j ACCEPT || true
      iptables -D FORWARD -o wg0 -j ACCEPT || true
    '';
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;

    privateKeyFile = "/etc/wireguard/arthur-private.key";

    peers = [
      {
        # marcus
        publicKey = "S2adus+n+YlQjks2qi9aZIrvRh0TJZD8vTSQZPKhUhA=";
        allowedIPs = [ "10.100.0.4/32" ];
      }
      {
        # mac
        publicKey = "/Hulinkd+T02SMfw3TLMorxaEZPahrozh4StsNLcyzU=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        # iphone
        publicKey = "VkeUtvWDmKzcxqxeyHULEIDbNBcE3pGBjQMt2K2Czy0=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
    ];
  };
}
