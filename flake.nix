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
    # FIXME: Temporary pin to bypass broken libghostty-vt requirement in devenv 2.1
    devenv.url = "github:cachix/devenv/070577452d0c81d62168ef8b158ee4317ace7e21";
    ghostty.url = "github:mitchellh/ghostty";
    devenv.inputs.ghostty.follows = "ghostty";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
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
        ultimate = ./shells/ultimate.nix;
        jail = ./modules/jail.nix;
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
            ];
          };
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            settings.global.excludes = [
              "./.agent/**"
              "./.devenv/**"
              "./.direnv/**"
              "flake.lock"
              "*.zip"
              "*.png"
              "*.jpg"
              "*.vscdb*"
            ];
            programs = {
              # Nix
              nixfmt.enable = true;
              statix.enable = true;
              deadnix.enable = true;
              # Shell
              shellcheck.enable = true;
              shfmt.enable = true;
              # Python — ruff format only (black-compatible, applies automatically on
              # `just maintenance::fmt`). The lint side (`ruff check`) is invoked on
              # demand via `just maintenance::lint-python` so a 77-error backlog from
              # legacy scripts doesn't block every format run.
              ruff-format.enable = true;
              # Go
              gofmt.enable = true;
            };
          };
        in
        {
          _module.args.pkgs = pkgs;
          _module.args.system = system;
          formatter = treefmtEval.config.build.wrapper;

          devenv.modules = [
            (_: {
              overlays = [
                (_: prev: {
                  libghostty-vt = (inputs.ghostty.packages.${system} or { }).libghostty-vt or prev.hello;
                })
              ];
            })
          ];

          devenv.shells =
            let
              # Using hardcoded path for local development to avoid read-only store issues
              localRoot = "/home/martin/Develop/github.com/kleinbem/nix/nix-devshells";
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
              ultimate = mkShell self.devenvModules.ultimate;
            };
        };
    };
}
