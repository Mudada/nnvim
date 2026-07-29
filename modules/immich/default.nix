{
  ...
}:
{
  services.immich = {
    enable = true;
    mediaLocation = "/media/immich";
    host = "0.0.0.0";
    openFirewall = false;
  };

  systemd.tmpfiles.rules = [
    "d /media/immich 0750 immich immich -"
  ];
}
