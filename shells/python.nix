{ pkgs, ... }:
{
  languages.python = {
    enable = true;
    uv.enable = true;
  };
  packages = [ pkgs.ruff ];
  enterShell = ''
    echo "🐍 Python DevShell Loaded"
  '';
}
