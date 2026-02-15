{ pkgs, ... }: {
  languages.go = {
    enable = true;
  };
  packages = [ pkgs.gopls pkgs.delve ];
  enterShell = ''
    echo "🐹 Go DevShell Loaded"
  '';
}
