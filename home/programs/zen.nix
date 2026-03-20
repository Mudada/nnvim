{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  zenConfig = config.programs.zen-browser;

  mkEngine =
    {
      name,
      alias,
      url,
    }:
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
    inputs.zen-browser.homeModules.beta
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
            decentraleyes
            localcdn
            proton-pass
            proton-vpn
            refined-github
            ublock-origin
            qwant-search
          ];
          force = true;
        };

        search = {
          default = "qwant";
          privateDefault = "qwant";
          engines = {
            nix-packages = mkEngine {
              name = "Nix packages";
              url = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
              alias = "@pkgs";
            };
            nixos-wiki = mkEngine {
              name = "NixOS Wiki";
              url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
              alias = "!nw";
            };
            home-manager = mkEngine {
              name = "Home manager options";
              url = "https://home-manager-options.extranix.com/?query={searchTerms}";
              alias = "@home";
            };
            cc-admin = mkEngine {
              name = "Clever cloud admin panel";
              url = "https://admin.clever-cloud.com/magicsearch?query={searchTerms}";
              alias = "@ccadmin";
            };
            cc-console = mkEngine {
              name = "Clever cloud console";
              url = "https://console.clever-cloud.com/?search={searchTerms}";
              alias = "@console";
            };
            naver = mkEngine {
              name = "Naver english dictionnary";
              url = "https://en.dict.naver.com/#/search?query={searchTerms}";
              alias = "@naver";
            };
            qwant = mkEngine {
              name = "Qwant";
              url = "https://www.qwant.com/?q={searchTerms}";
              alias = "@qwant";
            };
            gitlab-clever = mkEngine {
              name = "Gitlab clever";
              url = "https://gitlab.corp.clever-cloud.com/search?search={searchTerms}";
              alias = "@lab";
            };
            hoogle = mkEngine {
              name = "Hoogle haskell research";
              url = "https://hoogle.haskell.org/?hoogle={searchTerms}";
              alias = "@hoogle";
            };
            "google".metaData.hidden = true;
            "bing".metaData.hidden = true;
            "wikipedia".metaData.hidden = true;
            "perplexity".metaData.hidden = true;
          };
          force = true;
        };

        settings = {
        };
      };
    };
  };
}
