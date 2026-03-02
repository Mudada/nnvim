{
  pkgs,
  inputs,
  sys,
  ...
}:
{

  home.packages = [
    inputs.nv-dark-notify.packages.${sys}.default
    pkgs.discord
    pkgs.slack
    pkgs.zoom-us
    pkgs.nodejs_24
    # yubikey
    pkgs.gnupg
    pkgs.yubikey-manager
    pkgs.wireguard-tools
  ];

  home.file.".config/aerospace/aerospace.toml".source = ../modules/darwin/aerospace.toml;

}
