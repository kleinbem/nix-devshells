{
  pkgs,
  inputs,
  system,
  ...
}:
let
  pkgsMaster = import inputs.nixpkgs-master {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  env.DEV_SHELL_NAME = "ai-dev";
  env.STARSHIP_SHELL_SYMBOL = "🤖 ";

  scripts.inventory.exec = ''
    echo "$STARSHIP_SHELL_SYMBOL $DEV_SHELL_NAME Inventory (Live Audit):"
    ls $DEVENV_PROFILE/bin | grep -vE "(-[0-9]|\.sh|@|pkg-config|inventory|process-compose|crityp|typlite|mkoctfile|octave-config)" | sort -u | while read bin; do
      version_raw=$($bin --version 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1)
      if [ $? -eq 0 ]; then
        printf "  ✅ %-15s (%s)\n" "$bin" "''${version_raw:-active}"
      else
        printf "  ❌ %-15s (BROKEN)\n" "$bin"
      fi
    done
  '';

  enterShell = "inventory";

  packages = [
    pkgsMaster.claude-code
    pkgs.github-copilot-cli
    pkgs.gemini-cli
    pkgs.fabric-ai
    pkgs.lmstudio
    pkgs.alpaca
    (pkgs.python3Packages.llm.overridePythonAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    }))
  ];
}
