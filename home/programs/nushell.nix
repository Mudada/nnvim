{
  config,
  username,
  ...
}:
let
  userScriptPath = "${config.home.homeDirectory}/scripts/${username}";
in
{
  programs.nushell = {
    enable = true;
    configFile.source = ./nushell/config.nu;
    envFile.source = ./nushell/env.nu;
    extraEnv = ''
            let username = "${username}"
            $env.PATH = ([
      	$"/etc/profiles/per-user/($username)/bin"
      	$"/Users/($username)/.nix-profile/bin"
            ] ++ $env.PATH)
    '';
    extraConfig = ''
      source ${userScriptPath}.nu
    ''; # TODO: lib.mkIf (builtins.pathExists userScriptPath) "source ${userScriptPath}.nu";
  };

  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;
}
