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
    devenv.url = "github:cachix/devenv/v1.3.1";
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

      flake.devenvModules.default = { pkgs, ... }: {
        name = "meta-default";
        pre-commit.hooks = {
          nixfmt.enable = true;
          statix.enable = true;
          deadnix.enable = true;
        };
        packages = [
          pkgs.aider-chat
          pkgs.statix
          pkgs.nixfmt
          pkgs.deadnix
          pkgs.nil
          pkgs.sops
          pkgs.age
          pkgs.age-plugin-yubikey
          inputs.nixos-generators.packages.${pkgs.system}.nixos-generate
          pkgs.just
          pkgs.lazygit
          pkgs.gh
          pkgs.jq
          pkgs.ripgrep
          pkgs.fzf
          pkgs.android-tools
        ];
        enterShell = ''
          echo "🤖 DevShell Loaded (Devenv)"
          unset SSH_ASKPASS_REQUIRE
          unset SSH_ASKPASS
        '';
      };

      perSystem =
        {
          pkgs,
          system,
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

          devenv.shells = {
            default = {
              imports = [ self.devenvModules.default ];
            };

            python = {
              languages.python = {
                enable = true;
                uv.enable = true;
              };
              packages = [ pkgs.ruff ];
              enterShell = ''
                echo "🐍 Python DevShell Loaded"
              '';
            };

            rust = {
              languages.rust = {
                enable = true;
                channel = "stable";
              };
              packages = [ pkgs.rust-analyzer pkgs.clippy pkgs.rustfmt ];
              enterShell = ''
                echo "🦀 Rust DevShell Loaded"
              '';
            };

            go = {
              languages.go = {
                enable = true;
              };
              packages = [ pkgs.gopls pkgs.delve ];
              enterShell = ''
                echo "🐹 Go DevShell Loaded"
              '';
            };

            node = {
              languages.javascript = {
                enable = true;
                npm.enable = false;
                pnpm.enable = true;
              };
              languages.typescript.enable = true;
              packages = [ pkgs.nodejs_20 ];
              enterShell = ''
                echo "📦 Node DevShell Loaded"
              '';
            };

            full-stack = {
              services.postgres.enable = true;
              services.redis.enable = true;
              
              # Example scripts to run things
              scripts.run-all.exec = ''
                echo "Starting services..."
                devenv up
              '';

              enterShell = ''
                echo "🚀 Full Stack DevShell Loaded"
              '';
            };

            ai = {
              languages.python = {
                enable = true;
                uv.enable = true;
              };
              packages = [ pkgs.ollama ];
              processes.ollama.exec = "ollama serve";
              enterShell = ''
                echo "🤖 AI DevShell Loaded (Ollama Ready - 'devenv up' to start)"
              '';
            };
          };
        };
    };
}
