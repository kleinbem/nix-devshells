{
  lib,
  inputs ? { },
  system ? "x86_64-linux",
  ...
}:

{
  imports = [
    ./apps.nix
    ./pentest.nix
    ./ai-dev.nix
    ./math.nix
    ./media.nix
  ];

  devenv.root = lib.mkForce "/home/martin/Develop/github.com/kleinbem/nix";

  # NOTE: do NOT re-declare `_module.args.inputs`/`system` here. mkShell (flake.nix)
  # already injects both into every shell's module args. Re-assigning
  # `_module.args.system = system` is circular (its own `system` arg is sourced
  # from `_module.args.system`) and caused `nix flake check` to hit infinite
  # recursion on `devenv.shells.ultimate.packages` (apps/pentest filter on
  # `availableOn system`, which forces the cycle).

  env = {
    DEV_SHELL_NAME = lib.mkForce "ultimate";
    STARSHIP_SHELL_SYMBOL = lib.mkForce "🌌 ";
    WORDLISTS = lib.mkForce "${inputs.nixpkgs.legacyPackages.${system}.seclists}/share/wordlists";
  };

  scripts.inventory.exec = lib.mkForce ''
    echo "$STARSHIP_SHELL_SYMBOL $DEV_SHELL_NAME Inventory (Live Audit):"
    # Filter for primary binaries (ignore versioned duplicates, aliases, and internal scripts)
    ls $DEVENV_PROFILE/bin | grep -vE "(-[0-9]|\.sh|@|pkg-config|inventory|process-compose|crityp|typlite|mkoctfile|octave-config)" | sort -u | while read bin; do
      # SMOKE TEST: Try to get version, if it fails completely, mark as NOK
      version_raw=$($bin --version 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1)
      if [ $? -eq 0 ]; then
        printf "  ✅ %-15s (%s)\n" "$bin" "''${version_raw:-active}"
      else
        printf "  ❌ %-15s (BROKEN)\n" "$bin"
      fi
    done
  '';
  enterShell = "inventory";
}
