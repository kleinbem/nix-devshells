{
  description = "Development Shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    ghostty.url = "github:mitchellh/ghostty";
    devenv.inputs.ghostty.follows = "ghostty";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    # colmena main: nixpkgs only packages the old v0.4.0 tag. No nixpkgs
    # `follows`, since colmena builds against the nixpkgs it pins itself.
    colmena.url = "github:nix-community/colmena";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Packages the fleet holds back from nixos-unstable while they're broken
    # there (kleinbem/nix-detour-fleet); replaces the old fallbacks.nix overlay.
    nix-detour-fleet = {
      url = "github:kleinbem/nix-detour-fleet";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModules.default
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      flake.devenvModules = {
        default = ./shells/default/default.nix;
        python = ./shells/python.nix;
        nushell = ./shells/nushell.nix;
        rust = ./shells/rust.nix;
        go = ./shells/go.nix;
        node = ./shells/node.nix;
        full-stack = ./shells/full-stack.nix;
        ai = ./shells/ai.nix;
        ai-dev = ./shells/ai-dev.nix;
        pentest = ./shells/pentest.nix;
        math = ./shells/math.nix;
        media = ./shells/media.nix;
        apps = ./shells/apps.nix;
        android = ./shells/android.nix;
        lua = ./shells/lua.nix;
        arm = ./shells/arm.nix;
        workspace = ./shells/workspace.nix;
        openwrt = ./shells/openwrt.nix;
        esphome = ./shells/esphome.nix;
        ultimate = ./shells/ultimate.nix;
        jail = ./modules/jail.nix;
        parking = ./shells/parking.nix;
      };

      flake.homeManagerModules = {
        desktopLaunchers = ./modules/home-manager.nix;
      };

      perSystem =
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
            overlays = [
              (_: prev: {
                libghostty-vt = (inputs.ghostty.packages.${system} or { }).libghostty-vt or prev.hello;
              })
              inputs.nix-detour-fleet.overlays.default
            ];
          };
          # Shared formatter config (excludes + programs), reused by the
          # per-flake formatter and the meta-workspace formatter below.
          treefmtExcludes = [
            "./.agent/**"
            "./.devenv/**"
            "./.direnv/**"
            "flake.lock"
            "*.zip"
            "*.png"
            "*.jpg"
            "*.vscdb*"
          ];
          treefmtPrograms = {
            # Nix
            nixfmt.enable = true;
            statix.enable = true;
            deadnix.enable = true;
            # Shell
            shellcheck.enable = true;
            shfmt.enable = true;
            # Python: ruff format only. `ruff check` runs separately
            # (`just maintenance::lint-python`) so lint errors don't block formatting.
            ruff-format.enable = true;
            # Go
            gofmt.enable = true;
          };
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            settings.global.excludes = treefmtExcludes;
            programs = treefmtPrograms;
          };
          # formatter-meta: for the meta repos, which have no flake.nix of their own.
          # Used by nix/.just/maintenance.just (format-all, lint-all). The nix-*/
          # exclude keeps it out of the sibling sub-flakes.
          treefmtEvalMeta = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "repos.nix";
            settings.global.excludes = treefmtExcludes ++ [ "nix-*/**" ];
            programs = treefmtPrograms;
          };
        in
        {
          _module.args.pkgs = pkgs;
          _module.args.system = system;
          formatter = treefmtEval.config.build.wrapper;
          packages = {
            # Runnable meta-workspace formatter: `nix run ./nix-devshells#formatter-meta -- [--fail-on-change]`
            formatter-meta = treefmtEvalMeta.config.build.wrapper;

            # Decoupled standalone app packages (for direct launchers & isolated runs)
            inherit (pkgs)
              slack
              bruno
              qbittorrent
              wireshark
              burpsuite
              zenmap
              zap
              ;
            inherit (pkgs) "github-desktop" "ente-auth";
            dbeaver = pkgs.dbeaver-bin;
            rustdesk = pkgs.rustdesk-flutter;
            obs = pkgs.obs-studio;
          };

          devenv.modules = [
            (_: {
              overlays = [
                (_: prev: {
                  libghostty-vt = (inputs.ghostty.packages.${system} or { }).libghostty-vt or prev.hello;
                })
                inputs.nix-detour-fleet.overlays.default
              ];
            })
          ];

          devenv.shells =
            let
              # Using hardcoded path for local development to avoid read-only store issues
              localRoot = "/home/martin/Develop/github.com/kleinbem/nix-devshells";
              mkShell =
                module:
                {
                  imports = [ module ];
                  devenv.root = localRoot;
                }
                // {
                  # Pass inputs to the module arguments
                  _module.args = {
                    inherit inputs system;
                    libghostty-vt = pkgs.hello; # Use hello as a dummy package
                  };
                };
            in
            {
              default = mkShell self.devenvModules.default;
              python = mkShell self.devenvModules.python;
              nushell = mkShell self.devenvModules.nushell;
              rust = mkShell self.devenvModules.rust;
              go = mkShell self.devenvModules.go;
              node = mkShell self.devenvModules.node;
              full-stack = mkShell self.devenvModules.full-stack;
              ai = mkShell self.devenvModules.ai;
              ai-dev = mkShell self.devenvModules.ai-dev;
              pentest = mkShell self.devenvModules.pentest;
              math = mkShell self.devenvModules.math;
              media = mkShell self.devenvModules.media;
              apps = mkShell self.devenvModules.apps;
              android = mkShell self.devenvModules.android;
              lua = mkShell self.devenvModules.lua;
              arm = mkShell self.devenvModules.arm;
              workspace = mkShell self.devenvModules.workspace;
              openwrt = mkShell self.devenvModules.openwrt;
              esphome = mkShell self.devenvModules.esphome;
              ultimate = mkShell self.devenvModules.ultimate;
              parking = mkShell self.devenvModules.parking;
            };
        };
    };
}
