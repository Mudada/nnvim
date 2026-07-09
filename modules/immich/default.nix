{
  ...
}:
{
  services.immich = {
    enable = true;
    mediaLocation = "/media/immich";
    openFirewall = false;
  };

  systemd.tmpfiles.rules = [
    "d /media/immich 0750 immich immich -"
  ];
}
