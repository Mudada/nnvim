{ config, pkgs, username, ...}:
{
  programs.niri = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    pavucontrol
    adwaita-icon-theme
    gtk4
  ];

  programs.xwayland.enable = true;

  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "catpuccin-mocha";
    };
    displayManager.sessionPackages = [ pkgs.niri ];
  };

  home-manager.users."${username}" = {

    home.file.".config/niri/config.kdl" = {
      source = ./config.kdl;
    };

    gtk = {
        enable = true;
        theme = {
          name = "Breeze-Dark";
          package = pkgs.libsForQt5.breeze-gtk;
        };
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
        cursorTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
      };

    systemd.user.services.niri = {
      Unit = {
	Description = "A scrollable-tiling Wayland compositor";
	BindsTo = "graphical-session.target";
	Before = "graphical-session.target";
	Wants = "graphical-session-pre.target";
	After = "graphical-session-pre.target";
      };
      Service = {
	Slice = "session.slice";
	Type = "notify";
	ExecStart = "${pkgs.niri}/bin/niri --session";
      };
    };

    systemd.user.services.xwayland-satellite = {
      Unit = {
	Description = "Xwayland outside your Wayland";
	BindsTo = "graphical-session.target";
	PartOf = "graphical-session.target";
	After = "graphical-session.target";
	Requisite = "graphical-session.target";
      };
      Service = {
	Type = "notify";
	NotifyAccess = "all";
	ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
	StandardOutput = "journal";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
