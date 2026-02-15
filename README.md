# Nix DevShells

This repository contains centralized development shells for the workspace.

## Shells

- `default`: The primary development shell containing:
  - `aider-chat` (AI Pair Programmer)
  - `sops` (Secrets management)
  - `age` (Encryption)
  - `nixfmt`, `statix`, `deadnix` (Nix tooling)
  - `jq`, `ripgrep`, `fzf` (Utilities)

- `python`: Python development (Python 3, uv, ruff)
- `rust`: Rust development (Cargo, rustc, clippy, rustfmt, rust-analyzer)
- `go`: Go development (Go, gopls, delve)
- `node`: Node.js development (Node 20, pnpm/corepack, typescript)
- `full-stack`: Example full-stack environment with Postgres, Redis, and process management.
- `ai`: AI development with Python (uv) and **Ollama** service integration.

## Architecture

This repository uses **[devenv](https://devenv.sh)** to define composable, declarative developer environments. 
Each shell is a Devenv module that automatically configures languages, checks, and services.

## Usage

### Local Development

Run `nix develop .#<shell-name>` to enter a shell locally.
Example: `nix develop .#python`

### As a Dependency (Recommended)

This repository exports `devenvModules` which you can import into your own `flake.nix`. This allows you to compose these shells into your project's environment.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    nix-devshells.url = "github:kleinbem/nix-devshells";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, ... }: {
        devenv.shells.default = {
          imports = [
            # Import the python shell configuration from nix-devshells
            inputs.nix-devshells.devenvModules.python
          ];

          # You must set the root for devenv to work correctly in your repo
          devenv.root = let
            in toString ./.;
        };
      };
    };
}
```

### Available Modules

- `default`: Common tools (git, nix tools, sops, etc.)
- `python`: Python 3, uv, ruff
- `rust`: Rust (stable), rust-analyzer, clippy, rustfmt
- `go`: Go, gopls, delve
- `node`: Node 20, pnpm, typescript
- `full-stack`: Postgres, Redis, scripts
- `ai`: Python (uv), Ollama
- `android`: Android SDK, Tools, Scrcpy, JDK
- `lua`: Lua, LSP, Stylua, Selene

