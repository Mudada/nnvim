{
  ...
}:
{
  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      add_newline = true;
    };
  };

  programs.bat = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
  };

  programs.jq = {
    enable = true;
  };
}
