{ pkgs, ... }: {
  languages.lua = {
    enable = true;
  };

  packages = [
    pkgs.lua-language-server
    pkgs.stylua
    pkgs.selene
  ];

  enterShell = ''
    echo "🌙 Lua DevShell Loaded"
  '';
}
