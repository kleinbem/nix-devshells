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

# List the devShells this flake exposes for the current system.
[group("Discovery")]
list-shells:
    @echo "🐚 Available shells:"
    @nix eval ".#devShells.$(nix eval --impure --raw --expr builtins.currentSystem)" --apply 'builtins.attrNames' --json \
        | jq -r '.[]'
