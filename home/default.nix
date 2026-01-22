{
  config,
  pkgs,
  username,
  email,
  sys,
  ...
}:
let
  toLuaFile = file: "${builtins.readFile file}";
  userScriptPath = "${config.home.homeDirectory}/scripts/${username}";
  systemHome = if sys == "aarch64-darwin" then ./osx.nix else ./linux.nix;
in
{
  imports = [
    systemHome
    ../modules/zen.nix
    ../modules/zed
  ];

  home.stateVersion = "25.11";
  home.username = username;

  home.packages = [
    pkgs.ripgrep
    pkgs.metals
    pkgs.fd
    pkgs.pueue
    pkgs.coursier
    pkgs.ripgrep
    pkgs.pgcli
    (pkgs.callPackage ./../modules/monacob2.nix { })
    pkgs.wezterm
    pkgs._1password-cli
    pkgs.ragenix
    pkgs.rage
    pkgs.age-plugin-1p
    pkgs.claude-code
    pkgs.helix
    pkgs.nixd
    pkgs.anki-bin
  ];

  programs.zen-browser = {
    enable = true;
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "pipi-de-chat";
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
          name = "scala";
          language-servers = [ "metals" ];
        }
      ];
    };
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      ${toLuaFile ../wezterm/config.lua}
      conf.default_prog = {'/etc/profiles/per-user/${username}/bin/nu'}
      return(conf)
    '';
  };

  programs.zed-editor.enable = true;

  programs.kitty = {
    enable = true;
    font = {
      name = "monospace";
      size = 12;
    };
    settings = {
      shell = "/etc/profiles/per-user/${username}/bin/nu";
      editor = "hx";
      enabled_layouts = "splits";
      hide_window_decorations = "titlebar-only";
      window_padding_width = 4;
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      macos_option_as_alt = true;
      macos_quit_when_last_window_closed = true;
    };
    keybindings = {
      # Vertical split
      "opt+v" = "launch --location=vsplit";
      # Close panel
      "opt+x" = "close_window";
      # Tab switching with cmd+number
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";
      # New tab
      "cmd+t" = "new_tab";
      # Close tab
      "cmd+w" = "close_tab";
    };
  };

  programs.nushell = {
    enable = true;
    configFile.source = ../modules/nushell/config.nu;
    envFile.source = ../modules/nushell/env.nu;
    extraEnv = ''
            let username = "${username}"
            $env.PATH = ($env.PATH ++ [
      	$"/etc/profiles/per-user/($username)/bin"
      	$"/Users/($username)/.nix-profile/bin"
            ])
    '';
    extraConfig = ''
      source ${userScriptPath}.nu
    ''; # TODO: lib.mkIf (builtins.pathExists userScriptPath) "source ${userScriptPath}.nu";
  };

  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;

  home.file = {
    "scripts" = {
      source = ../scripts;
      recursive = true;
    };
    ".config/kitty/dark-theme.auto.conf".source = ../kitty/rose-pine-dark.conf;
    ".config/kitty/light-theme.auto.conf".source = ../kitty/rose-pine-light.conf;
    ".config/helix/themes/pipi-de-chat.toml".text = ''
      inherits = "catppuccin_latte"

      [palette]
      base = "#FDFFDF"
    '';
  };

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
