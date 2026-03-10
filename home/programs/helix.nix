{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.helix
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "boo_berry";
      editor = {
        line-number = "relative";
        color-modes = true;
      };
      editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
    };
    languages = {
      language-server.metals = {
        command = "${pkgs.metals}/bin/metals";
        config = {
          isHttpEnabled = true;
          metals = {
            startMcpServer = true;
          };
        };
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        }
        {
          name = "nu";
          auto-format = true;
          language-servers = [ ]; # fuck you fucking shit ass shit
        }
        {
          name = "scala";
          language-servers = [ "metals" ];
        }
      ];
    };
  };

  home.file.".config/helix/themes/pipi-de-chat.toml".text = ''
    inherits = "catppuccin_latte"

    [palette]
    base = "#FDFFDF"
  '';
}
