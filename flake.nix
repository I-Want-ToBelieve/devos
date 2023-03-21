{
  description = "A highly structured configuration database.";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://fortuneteller2k.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://helix.cachix.org"
      "https://hyprland.cachix.org"
      "https://nrdxp.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "fortuneteller2k.cachix.org-1:kXXNkMV5yheEQwT0I4XYh1MaCSz+qg72k8XAi2PthJI="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4="
    ];
  };

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Track channels with commits tested and built by hydra
    nixos.url = "github:nixos/nixpkgs/nixos-22.11";
    latest.url = "github:nixos/nixpkgs/nixos-unstable";
    # For darwin hosts: it can be helpful to track this darwin-specific stable
    # channel equivalent to the `nixos-*` channels for NixOS. For one, these
    # channels are more likely to provide cached binaries for darwin systems.
    # But, perhaps even more usefully, it provides a place for adding
    # darwin-specific overlays and packages which could otherwise cause build
    # failures on Linux systems.
    nixpkgs-darwin-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.11-darwin";

    digga.url = "github:divnix/digga";
    digga.inputs.nixpkgs.follows = "nixos";
    digga.inputs.nixlib.follows = "nixos";
    digga.inputs.home-manager.follows = "home-manager";
    digga.inputs.deploy.follows = "deploy";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixos";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin-stable";

    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixos";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixos";

    nvfetcher.url = "github:berberman/nvfetcher";
    nvfetcher.inputs.nixpkgs.follows = "nixos";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib.url = "github:hyprwm/contrib";
    xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix.url = "github:helix-editor/helix";
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    # Non Flakes
    sf-mono-liga = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };

    # my nur repository for my nixos dotfiles
    inur = {
      url = "github:I-Want-ToBelieve/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    digga,
    nixos,
    home-manager,
    nixos-hardware,
    nur,
    agenix,
    nvfetcher,
    deploy,
    rust-overlay,
    nixpkgs,
    ...
  } @ inputs: let
    configs = import ./configs {};
  in
    digga.lib.mkFlake
    {
      inherit self inputs;

      channelsConfig = {allowUnfree = true;};

      channels = {
        nixos = {
          imports = [(digga.lib.importOverlays ./overlays)];
          overlays = [
          ];
        };
        nixpkgs-darwin-stable = {
          imports = [(digga.lib.importOverlays ./overlays)];
          overlays = [
            # TODO: restructure overlays directory for per-channel overrides
            # `importOverlays` will import everything under the path given
            (channels: final: prev:
              {
                inherit (channels.latest) mas;
              }
              // prev.lib.optionalAttrs true {})
          ];
        };
        latest = {
          imports = [(digga.lib.importOverlays ./overlays)];
          overlays = [
          ];
        };
      };

      lib = import ./lib {lib = digga.lib // nixos.lib;};

      sharedOverlays = [
        (final: prev: {
          __dontExport = true;
          lib = prev.lib.extend (lfinal: lprev: {
            our = self.lib;
          });
        })
        (final: prev: {
          inur = inputs.inur.packages."${prev.system}";
        })
        (
          final: _: let
            inherit (final) system;
          in
            {
              # Packages provided by flake inputs
              crane-lib = inputs.crane.lib.${system};
            }
            // {
              # Non Flakes
              sf-mono-liga-src = inputs.sf-mono-liga;
            }
        )
        nur.overlay
        agenix.overlays.default
        nvfetcher.overlays.default
        rust-overlay.overlays.default
        (import ./pkgs)
      ];

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "latest";
          imports = [(digga.lib.importExportableModules ./modules)];
          modules =
            [
              {lib.our = self.lib;}
              digga.nixosModules.bootstrapIso
              digga.nixosModules.nixConfig
              home-manager.nixosModules.home-manager
              agenix.nixosModules.age
              {
                system.stateVersion = "22.11";
                system.autoUpgrade.enable = false;
              }
            ]
            ++ (
              if configs.useDE
              then []
              else [inputs.hyprland.nixosModules.default]
            );
        };

        imports = [(digga.lib.importHosts ./hosts/nixos)];
        hosts = {
          # set host-specific properties here
          NixOS = {};
          k99-lite = {
            modules = [
              ({suites, ...}: {
                imports =
                  suites.base
                  ++ suites.misc
                  ++ suites.game
                  ++ (
                    if configs.useDE
                    then suites.kde-x11
                    else suites.hyprland
                  );
              })
            ];
          };
        };
        importables = rec {
          profiles =
            digga.lib.rakeLeaves ./profiles
            // {
              users = digga.lib.rakeLeaves ./users;
            };
          suites = with profiles; rec {
            base = [core.nixos users.nixos users.root users."i.want.to.believe"];
            kde-x11 = [display-managers.sddm desktop-environment.kde];
            kde-wayland = [display-managers.sddm];
            hyprland = [display-managers.greetd];
            misc = [network nix locale fonts];
            game = [game.steam];
          };
        };
      };

      darwin = {
        hostDefaults = {
          system = "x86_64-darwin";
          channelName = "nixpkgs-darwin-stable";
          imports = [(digga.lib.importExportableModules ./modules)];
          modules = [
            {lib.our = self.lib;}
            digga.darwinModules.nixConfig
            home-manager.darwinModules.home-manager
            agenix.nixosModules.age
          ];
        };

        imports = [(digga.lib.importHosts ./hosts/darwin)];
        hosts = {
          # set host-specific properties here
          Mac = {};
        };
        importables = rec {
          profiles =
            digga.lib.rakeLeaves ./profiles
            // {
              users = digga.lib.rakeLeaves ./users;
            };
          suites = with profiles; rec {
            base = [core.darwin users.darwin];
          };
        };
      };

      home = {
        imports = [(digga.lib.importExportableModules ./users/modules)];
        modules = [inputs.hyprland.homeManagerModules.default] ++ [{home.stateVersion = "22.11";}];
        importables = rec {
          profiles = digga.lib.rakeLeaves ./users/profiles;
          suites = with profiles; {
            base = [packages nix misc];
            cli = with cli; [direnv git ssh starship helix];
            gui = with gui; [firefox discord fcitx5 kitty mpd obs-studio vscode zathura];
            shells = with shells; [fish zsh];
            hyprland = with desktop; [dunst waybar window-managers.hyprland gtk rofi swaylock];
            kde-x11 = [];
            kde-wayland = [];
          };
        };
        users = {
          # TODO: does this naming convention still make sense with darwin support?
          #
          # - it doesn't make sense to make a 'nixos' user available on
          #   darwin, and vice versa
          #
          # - the 'nixos' user might have special significance as the default
          #   user for fresh systems
          #
          # - perhaps a system-agnostic home-manager user is more appropriate?
          #   something like 'primaryuser'?
          #
          # all that said, these only exist within the `hmUsers` attrset, so
          # it could just be left to the developer to determine what's
          # appropriate. after all, configuring these hm users is one of the
          # first steps in customizing the template.
          nixos = {suites, ...}: {
            imports = suites.base;
          };
          darwin = {suites, ...}: {
            imports = suites.base;
          };
          "i.want.to.believe" = {
            suites,
            profiles,
            hostName,
            ...
          }: {
            imports =
              suites.base
              ++ suites.cli
              ++ suites.gui
              ++ suites.shells
              ++ (
                if configs.useDE
                then suites.kde-x11
                else suites.hyprland
              );
          };
        }; # digga.lib.importers.rakeLeaves ./users/hm;
      };

      devshell = ./shell;

      # TODO: similar to the above note: does it make sense to make all of
      # these users available on all systems?
      homeConfigurations =
        digga.lib.mergeAny
        (digga.lib.mkHomeConfigurations self.darwinConfigurations)
        (digga.lib.mkHomeConfigurations self.nixosConfigurations);

      deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations {};

      outputsBuilder = channels: {formatter = channels.latest.treefmt;};
    };
}
