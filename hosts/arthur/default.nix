{
  modulesPath,
  lib,
  pkgs,
  ...
}:
let
  user = "arthur";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
    ./forgejo-runner.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  age.identityPaths = [ "/etc/age/key" ];
  age.secrets."${user}-authorized-keys" = {
    file = ../../secrets/arthur-authorized-keys.age;
    path = "/etc/ssh/authorized_keys.d/${user}";
    mode = "0444";
  };

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbYSqyULc3swNtiKuh52qB0HpfwhYErRw86PsDBFzgf mudada@mudada.local"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.trusted-users = [
    "root"
    "${user}"
  ];

  home-manager.users.${user} = {
    home.stateVersion = "24.05";
  };

  system.stateVersion = "24.05";
}
