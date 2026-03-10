{
  config,
  username,
  email,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
    };
    matchBlocks."github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = config.age.secrets.ssh-personal.path;
      identitiesOnly = true;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = username;
      user.email = email;
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = username;
      user.email = email;
      ui.default-command = "log";
    };
  };
}
