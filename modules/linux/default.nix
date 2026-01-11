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
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "${username}" ];
  };
}
