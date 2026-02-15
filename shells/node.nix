{ pkgs, ... }: {
  languages.javascript = {
    enable = true;
    npm.enable = false;
    pnpm.enable = true;
  };
  languages.typescript.enable = true;
  packages = [ pkgs.nodejs_20 ];
  enterShell = ''
    echo "📦 Node DevShell Loaded"
  '';
}
