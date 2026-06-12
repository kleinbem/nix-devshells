{ pkgs, ... }:
{
  packages = [
    pkgs.nushell
  ];
  enterShell = ''
    echo "🐚 Nushell DevShell Loaded"
  '';
}
