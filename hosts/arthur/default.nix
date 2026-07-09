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

  environment.systemPackages = [ pkgs.gitMinimal pkgs.jujutsu ];

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
