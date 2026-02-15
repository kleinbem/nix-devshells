{
  description = "Development Shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
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
        rust = ./shells/rust.nix;
        go = ./shells/go.nix;
        node = ./shells/node.nix;
        full-stack = ./shells/full-stack.nix;
        ai = ./shells/ai.nix;
        android = ./shells/android.nix;
        lua = ./shells/lua.nix;
        jail = ./modules/jail.nix;
      };

      perSystem =
        {
          pkgs,
          ...
        }:
        let
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };
        in
        {
          formatter = treefmtEval.config.build.wrapper;

          devenv.shells = let
            # Using hardcoded path for local development to avoid read-only store issues
            localRoot = "/home/martin/Develop/github.com/kleinbem/nix/nix-devshells";
            mkShell = module: {
              imports = [ module ];
              devenv.root = localRoot;
            };
          in {
            default = mkShell self.devenvModules.default;
            python = mkShell self.devenvModules.python;
            rust = mkShell self.devenvModules.rust;
            go = mkShell self.devenvModules.go;
            node = mkShell self.devenvModules.node;
            full-stack = mkShell self.devenvModules.full-stack;
            ai = mkShell self.devenvModules.ai;
            android = mkShell self.devenvModules.android;
            lua = mkShell self.devenvModules.lua;
          };
        };
    };
}
