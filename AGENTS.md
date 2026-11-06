# nix-devshells

Centralized development shells for the workspace, built with
**[devenv](https://devenv.sh)** — each shell is a composable devenv module.

## Layout

| Path | What lives here |
|---|---|
| `shells/` | Per-shell devenv modules (`default`, `python`, `rust`, `go`, `node`, `full-stack`, `ai`). |
| `modules/` | Shared devenv module fragments reused across shells. |
| `pkgs/` | Custom packages exposed alongside the shells. |

## Conventions

- Every other repo in the fleet consumes shells from here via
  `inputs.nix-devshells.follows` — changing a shell's package set or
  service config has fleet-wide blast radius across whoever's `.envrc`
  loads it (typically `#workspace` or a domain-specific shell like
  `#openwrt`).
- Add a new shell as its own devenv module under `shells/`, not by
  overloading an existing one with unrelated tooling.
