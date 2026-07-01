# OS disk layout for sda (447GB).
# sdb + sdc are the media RAID1 disks — formatted manually (see system.nix).
#
# To apply during fresh install (from NixOS live USB):
#   sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
#     --mode disko --flake /path/to/config#marcus
#   sudo nixos-install --no-root-password --flake /path/to/config#marcus
{
  disko.devices.disk.boot = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "noatime" ];
            };
          };
        };
      };
    };
  };
}
