{ pkgs, lib, ... }:
{
  scripts.inventory.exec = lib.mkDefault ''
    echo "$STARSHIP_SHELL_SYMBOL $DEV_SHELL_NAME Inventory (Live Audit):"
    # Filter for primary binaries (ignore versioned duplicates, aliases, and internal scripts)
    ls "$DEVENV_PROFILE/bin" | grep -vE "(-[0-9]|\.sh|@|pkg-config|inventory|process-compose|crityp|typlite|mkoctfile|octave-config)" | sort -u | while read -r bin; do
      # Timeout and closed stdin: a GUI tool that ignores --version would
      # otherwise block shell entry. Only "can't execute" counts as broken,
      # since many tools exit non-zero on --version.
      rc=0
      out=$(${pkgs.coreutils}/bin/timeout 3 "$bin" --version </dev/null 2>/dev/null) || rc=$?
      if [ "$rc" -eq 126 ] || [ "$rc" -eq 127 ]; then
        printf "  ❌ %-15s (BROKEN)\n" "$bin"
      elif [ "$rc" -eq 124 ]; then
        printf "  ⏱️  %-15s (no --version, timed out)\n" "$bin"
      else
        version_raw=$(printf '%s\n' "$out" | head -n 1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1 || true)
        printf "  ✅ %-15s (%s)\n" "$bin" "''${version_raw:-active}"
      fi
    done
  '';

  enterShell = lib.mkDefault "inventory";
}
