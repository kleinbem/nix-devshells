{
  inputs,
  system,
}:
let
  stablePkgs = import inputs.nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in
# Fleet Circuit Breaker Fallback Overlay
# When any package or tool regresses/breaks on nixos-unstable, add its override here.
# This automatically protects:
#   1. Standalone package exports (`packages.<app>`)
#   2. Desktop launchers (`nix run "${cfg.flakePath}#<app>"`)
#   3. Devenv shells (`devenv.shells.<name>`)
#
# When upstream fixes the package, simply remove the override from this set.
_final: _prev: {
  inherit stablePkgs;

  # Active circuit breakers:
  # Example:
  # rustdesk-flutter = stablePkgs.rustdesk-flutter;
}
