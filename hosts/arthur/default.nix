# Arthur — WireGuard hub VPS that lets marcus be reached without a fixed home IP.
# Deploy: nixos-rebuild switch --flake .#arthur --target-host root@<arthur-ip>
{ modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/server
    ../../modules/wireguard/server.nix
    ../../modules/forgejo-runner
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    hostName = "arthur";
    useDHCP = true;
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "marcus" ];
  };

  environment.systemPackages = [ pkgs.gitMinimal pkgs.jujutsu pkgs.helix ];

  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme-marcus-tls.casing405@passmail.net";
      dnsProvider = "ovh";
      environmentFile = "/etc/acme/ovh-credentials";
    };
    certs."pisse.cloud" = {
      domain = "*.pisse.cloud";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."caca.pisse.cloud" = {
      useACMEHost = "pisse.cloud";
      forceSSL = true;
      extraConfig = ''
        client_max_body_size 50G;
        error_page 502 503 504 /maintenance.html;
      '';
      locations."/" = {
        proxyPass = "http://10.100.0.4:2283";
        proxyWebsockets = true;
      };
      locations."= /maintenance.html" = {
        alias = "${pkgs.writeText "maintenance.html" (builtins.readFile ./maintenance.html)}";
        extraConfig = "internal;";
      };
    };
    virtualHosts."ipod.pisse.cloud" = {
      useACMEHost = "pisse.cloud";
      forceSSL = true;
      extraConfig = ''
        error_page 502 503 504 /maintenance.html;
      '';
      locations."/" = {
        proxyPass = "http://10.100.0.4:8096";
        proxyWebsockets = true;
      };
      locations."= /maintenance.html" = {
        alias = "${pkgs.writeText "maintenance.html" (builtins.readFile ./maintenance.html)}";
        extraConfig = "internal;";
      };
    };
  };

  users.users.marcus = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbYSqyULc3swNtiKuh52qB0HpfwhYErRw86PsDBFzgf mudada@mudada.local"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "24.11";
}
