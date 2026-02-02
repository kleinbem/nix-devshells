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
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { config, pkgs, system, ... }:
        let
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };
        in
        {
          formatter = treefmtEval.config.build.wrapper;

          checks.pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt.enable = true;
              statix.enable = true;
              deadnix.enable = true;
            };
          };

          devShells.default = pkgs.mkShell {
            buildInputs = [
              pkgs.aider-chat
              pkgs.statix
              pkgs.nixfmt
              pkgs.deadnix
              pkgs.nil
              pkgs.sops
              pkgs.age
              pkgs.age-plugin-yubikey
              inputs.nixos-generators.packages.${system}.nixos-generate
            ];

            shellHook = ''
              ${config.checks.pre-commit-check.shellHook}
              echo "🤖 DevShell Loaded"
              unset SSH_ASKPASS_REQUIRE
              unset SSH_ASKPASS
            '';
          };
        };
    };
}
