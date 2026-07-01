{
  ...
}:
{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = null;
      UseDns = false;
      X11Forwarding = false;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    # WireGuard tunnel is trusted — Jellyfin is only reachable via VPN
    trustedInterfaces = [ "wg0" ];
  };
}
