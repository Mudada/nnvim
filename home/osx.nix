{ pkgs, inputs, sys, ... }: {

  home.packages = [
    inputs.nv-dark-notify.packages.${sys}.default
    pkgs.discord
    pkgs.slack
    pkgs.zoom-us
  ];

  home.file.".config/aerospace/aerospace.toml".source = ../modules/darwin/aerospace.toml;
}
