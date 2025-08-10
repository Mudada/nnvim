{ config, pkgs, lib, inputs, ... }:
let
  zenConfig = config.programs.zen-browser;

  mkEngine = { name, alias, url, }:
    {
      name = name;
      urls = [
        {
          template = url;
        }
      ];
      definedAliases = [ alias ];
    };
in
{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  config = lib.mkIf zenConfig.enable {
    programs.zen-browser = {
      policies = {
        DisableAppUpdate = true;

        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxStudies = true;
        DisableTelemetry = true;
        DisablePocket = true;

        DisableProfileImport = true;

        DisableSetDesktopBackground = true;
        NoDefaultBookmarks = false;

        DontCheckDefaultBrowser = true;

        HardwareAcceleration = true;

        HttpsOnlyMode = "force_enabled";

        ShowHomeButton = false;
        Homepage = {
          StartPage = "previous-session";
          Locked = true;
        };
        NewTabPage = false;

        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;

        DisableMasterPasswordCreation = true;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        PrimaryPassword = false;
      };
      profiles.default = {
	#preConfig = builtins.readFile "${inputs.betterfox.outPath}/zen/user.js";

        bookmarks = {
          settings = [
            {
              name = "Cloud";
              bookmarks = [
                {
                  name = "OVH";
                  url = "https://www.ovh.com";
                }
                {
                  name = "Cloudflare";
                  url = "https://dash.cloudflare.com";
                }
                {
                  name = "Clever Cloud";
                  url = "https://console.clever-cloud.com";
                }
                {
                  name = "Clever Cloud Par0";
                  url = "https://console.par0.clvrcld.net";
                }
              ];
            }
            {
              name = "Nix";
              bookmarks = [
                {
                  name = "Home Manager configuration options";
                  url = "https://nix-community.github.io/home-manager/options.xhtml";
                }
                {
                  name = "NixOS configuration options";
                  url = "https://nixos.org/manual/nixos/stable/options.html";
                }
                {
                  name = "Nix package versions";
                  url = "https://lazamar.co.uk/nix-versions/";
                }
              ];
            }
          ];
          force = true;
        };

        extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            proton-pass
            refined-github
            ublock-origin
          ];
          force = true;
        };

        search = {
          default = "qwant";
          privateDefault = "qwant";
          engines = {
            nix-packages = mkEngine {
              name = "Nix Packages";
              alias = "@pkgs";
              url = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
            };
            cc-admin = mkEngine {
              name = "Clever cloud admin panel";
              alias = "@ccadmin";
              url = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
            };
            cc-console = mkEngine {
              name = "Clever cloud console";
              alias = "@console";
              url = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
            };
            nixos-wiki = mkEngine {
              name = "NixOS Wiki";
              alias = "!nw";
              url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
            };
          };
          force = true;
        };

        settings = {
        };
      };
    };
  };
}
