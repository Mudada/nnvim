{
  pkgs,
  ...
}:
{
  services.jellyfin = {
    enable = true;
    openFirewall = false; # exposed only via WireGuard (wg0 is a trustedInterface)
    dataDir = "/var/lib/jellyfin";
    cacheDir = "/var/cache/jellyfin";
    # Media library roots are configured in the Jellyfin web UI after first boot.
    # Point your libraries to /media/jellyfin/<category>.
  };

  # NVENC hardware transcoding — give jellyfin access to nvidia devices
  systemd.services.jellyfin.serviceConfig = {
    SupplementaryGroups = [ "video" "render" ];
    DeviceAllow = [
      "char-drm rw"
      "/dev/nvidia0 rw"
      "/dev/nvidiactl rw"
      "/dev/nvidia-modeset rw"
      "/dev/nvidia-uvm rw"
      "/dev/nvidia-uvm-tools rw"
    ];
  };

  environment.systemPackages = [ pkgs.jellyfin-ffmpeg ];

  # Create media library directories owned by the jellyfin group
  systemd.tmpfiles.rules = [
    "d /media/jellyfin         0775 jellyfin jellyfin -"
    "d /media/jellyfin/movies  0775 jellyfin jellyfin -"
    "d /media/jellyfin/shows   0775 jellyfin jellyfin -"
    "d /media/jellyfin/music   0775 jellyfin jellyfin -"
    "d /media/jellyfin/photos  0775 jellyfin jellyfin -"
    "d /media/jellyfin/books   0775 jellyfin jellyfin -"
  ];
}
