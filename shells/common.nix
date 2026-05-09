{ lib, ... }:
{
  scripts.inventory.exec = lib.mkDefault ''
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

  enterShell = lib.mkDefault "inventory";
}
