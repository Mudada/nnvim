# cc-clamav.nix
{ lib, ... }:
let
  f = builtins.getEnv "CC_CLAMAV_CREDS";
  secrets = lib.strings.splitString " " f;
in
{
  cc-clamav = {
    url = "git+${builtins.elemAt secrets 3}";
    flake = false;
  };
}
