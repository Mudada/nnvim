{ pkgs, inputs, sys, ... }: {

  home.packages = [
    inputs.nv-dark-notify.packages.${sys}.default
    pkgs.discord
  ];

}
