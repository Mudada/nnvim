{
  pkgs,
  inputs,
  username,
  user,
  ...
}:
let
in
{
  programs._1password.enable = false;
  programs._1password-gui = {
    enable = false;
    polkitPolicyOwners = [ "${username}" ];
  };
}
