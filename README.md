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

Use this flake to power your `devShells` in other repositories.

```nix
inputs.nix-devshells.url = "github:kleinbem/nix-devshells";
# ...
devShells.default = inputs.nix-devshells.devShells.${system}.default;
```
