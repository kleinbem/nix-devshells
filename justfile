# nix-devshells Justfile
#
# Shared devshells and tooling consumed by the meta-workspace's devenv.

[group("Main")]
default:
    @just --list

[group("Linter")]
check:
    @echo "💻 Verifying devshells flake..."
    @nix flake check . --impure

[group("Linter")]
fmt:
    @nix fmt

# List home-manager modules exposed by this flake (the "shell preset" entry points).
[group("Discovery")]
list-shells:
    @echo "🐚 Available shell modules:"
    @nix eval .#homeManagerModules --apply 'builtins.attrNames' --json 2>/dev/null \
        | jq -r '.[]' 2>/dev/null \
        || nix flake show .
