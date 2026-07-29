{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  system.stateVersion = "24.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "marcus";
    networkmanager.enable = true;
    nameservers = [
      "86.54.11.13"
      "86.54.11.213"
      "2a13:1001::86:54:11:13"
      "2a13:1001::86:54:11:213"
    ];
  };

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # NVIDIA — modesetting only, no GUI; used for Jellyfin hardware transcoding (NVENC)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "jellyfin"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbYSqyULc3swNtiKuh52qB0HpfwhYErRw86PsDBFzgf mudada@mudada.local"
    ];
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    htop
    lsof
    btrfs-progs
  ];

  # ---------- Media disks (LUKS + btrfs RAID1) ----------
  # One-time setup after the OS is installed on sdb:
  #
  #   # 1. Generate keyfile (lives on the encrypted OS disk, embedded in initrd at rebuild)
  #   sudo mkdir -p /etc/luks-keys
  #   sudo dd if=/dev/urandom of=/etc/luks-keys/media bs=512 count=1
  #   sudo chmod 400 /etc/luks-keys/media
  #
  #   # 2. Encrypt both media disks with the keyfile
  #   sudo cryptsetup luksFormat /dev/sdb --key-file /etc/luks-keys/media
  #   sudo cryptsetup luksFormat /dev/sdc --key-file /etc/luks-keys/media
  #
  #   # 3. Open them
  #   sudo cryptsetup open /dev/sdb cryptmedia1 --key-file /etc/luks-keys/media
  #   sudo cryptsetup open /dev/sdc cryptmedia2 --key-file /etc/luks-keys/media
  #
  #   # 4. Create btrfs RAID1 on the decrypted devices
  #   sudo mkfs.btrfs -L media -d raid1 -m raid1 /dev/mapper/cryptmedia1 /dev/mapper/cryptmedia2
  #
  #   # 5. nixos-rebuild switch  (embeds keyfile into initrd)

  boot.initrd.secrets = {
    "/etc/luks-keys/media" = "/etc/luks-keys/media";
    "/etc/secrets/initrd/ssh_host_ed25519_key" = "/etc/secrets/initrd/ssh_host_ed25519_key";
  };

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22;
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbYSqyULc3swNtiKuh52qB0HpfwhYErRw86PsDBFzgf mudada@mudada.local"
      ];
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
  };

  boot.initrd.luks.devices = {
    cryptmedia1 = {
      device = "/dev/disk/by-uuid/d3bbbc89-f40c-433b-b2fe-1ed25d6b376b";
      keyFile = "/etc/luks-keys/media";
      keyFileSize = 512;
    };
    cryptmedia2 = {
      device = "/dev/disk/by-uuid/85299f54-21d2-49ba-8154-06a3068f4c86";
      keyFile = "/etc/luks-keys/media";
      keyFileSize = 512;
    };
  };

  fileSystems."/media" = {
    device = "/dev/disk/by-label/media";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "nofail"
      "x-systemd.device-timeout=10"
    ];
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/media" ];
  };

  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme-marcus-tls.casing405@passmail.net";
      dnsProvider = "ovh";
      environmentFile = "/etc/acme/ovh-credentials";
    };
    certs."t1fr.fr" = {
      domain = "*.t1fr.fr";
    };
    certs."pisse.cloud" = {
      domain = "*.pisse.cloud";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "ipod.t1fr.fr" = {
        useACMEHost = "t1fr.fr";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };
      "garage.t1fr.fr" = {
        useACMEHost = "t1fr.fr";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
      };
      "caca.t1fr.fr" = {
        useACMEHost = "t1fr.fr";
        forceSSL = true;
        extraConfig = "client_max_body_size 50G;";
        locations."/" = {
          proxyPass = "http://127.0.0.1:2283";
          proxyWebsockets = true;
        };
      };
    };
  };

  services.filebrowser = {
    enable = true;
    settings = {
      port = 8080;
      address = "0.0.0.0";
      root = "/media/jellyfin";
    };
  };

  systemd.services.filebrowser.serviceConfig = {
    User = lib.mkForce "jellyfin";
    Group = lib.mkForce "jellyfin";
    UMask = lib.mkForce "0022";
  };
}
