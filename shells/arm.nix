{
  pkgs,
  lib,
  ...
}:
{
  # This shell is optimized for ARM / Nix-on-Droid environments
  name = "arm-shell";

  packages = [
    pkgs.htop
    pkgs.btop
    pkgs.android-tools
    pkgs.nmap
    pkgs.fastfetch
  ]
  ++ lib.optional (pkgs ? termux-api) pkgs.termux-api;

  enterShell = ''
    echo "📱 ARM-Specific DevShell Loaded"
    if [[ "$(uname -m)" != "aarch64" ]]; then
      echo "⚠️  Note: You are running this shell via emulation ($(uname -m))"
    fi
  '';
}
