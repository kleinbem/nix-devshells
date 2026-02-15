{ pkgs, ... }: {
  languages.rust = {
    enable = true;
    channel = "stable";
  };
  packages = [ pkgs.rust-analyzer pkgs.clippy pkgs.rustfmt ];
  enterShell = ''
    echo "🦀 Rust DevShell Loaded"
  '';
}
