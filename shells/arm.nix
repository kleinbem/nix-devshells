{
  pkgs,
  lib,
  system,
  ...
}:
{
  # This shell is optimized for ARM / Nix-on-Droid environments
  name = "arm-shell";

  packages = lib.filter (pkg: lib.meta.availableOn system pkg) [
    pkgs.htop
    pkgs.btop
    pkgs.android-tools
    pkgs.nmap
    pkgs.termux-api # Only relevant if running inside Termux
    pkgs.fastfetch
  ];

  enterShell = ''
    echo "📱 ARM-Specific DevShell Loaded"
    if [[ "$(uname -m)" != "aarch64" ]]; then
      echo "⚠️  Note: You are running this shell via emulation ($(uname -m))"
    fi
  '';
}
