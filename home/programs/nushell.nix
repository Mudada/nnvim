{
  config,
  lib,
  username,
  ...
}:
let
  userScriptPath = "${config.home.homeDirectory}/scripts/${username}";
  scriptFiles = builtins.filter
    (f: lib.hasSuffix ".nu" f)
    (builtins.attrNames (builtins.readDir ../../scripts));
  useStatements = lib.concatMapStringsSep "\n" (f: "use ${f} *") scriptFiles;
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
      ${useStatements}
      source ${userScriptPath}.nu
    '';
  };

  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;
}
