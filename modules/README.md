# Modules

This nix-darwin/NixOS configuration is split into the following modules.

| Module | Description | Platform |
|--------|-------------|----------|
| [darwin](darwin/) | macOS system settings: Homebrew packages, keyboard remapping, dock preferences, Nix config | macOS |
| [linux](linux/) | 1Password CLI and GUI with polkit policy | NixOS |
| [niri](niri/) | Niri Wayland compositor with SDDM, XWayland, desktop portal, and GTK theming | NixOS |
| [nvim](nvim/) | Neovim via nixvim: LSP, DAP, Telescope, Treesitter, custom keybindings | Both |
| [system](system/) | NixOS base system: hardware, networking, locale, NVIDIA drivers, Bluetooth, SSH server | NixOS |
| [wireguard](wireguard/) | WireGuard VPN server with NAT and peer management ([README](wireguard/README.md)) | NixOS |
| [zed](zed/) | Zed editor: themes, extensions, vim mode, Metals/Scala LSP | Both |
| [zen.nix](zen.nix) | Zen browser: privacy policies, bookmarks, search engines, Firefox extensions | Both |
| [steam.nix](steam.nix) | Steam with remote play and dedicated server firewall rules | NixOS |

**Platform key**: macOS = `darwinConfigurations` only, NixOS = `nixosConfigurations` only, Both = imported via home-manager in both.
