{
  pkgs,
  username,
  ...
}:
let
  toLuaFile = file: "${builtins.readFile file}";
in
{
  home.packages = [
    pkgs.wezterm
  ];

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      ${toLuaFile ./wezterm/config.lua}
      conf.default_prog = {'/etc/profiles/per-user/${username}/bin/nu'}
      return(conf)
    '';
  };
}
