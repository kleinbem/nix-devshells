{
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
let
  unfreePkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  imports = [ ./common.nix ];

  env.DEV_SHELL_NAME = lib.mkDefault "apps";
  env.STARSHIP_SHELL_SYMBOL = lib.mkDefault "🏢 ";

  packages = [
    unfreePkgs.slack
    unfreePkgs.dbeaver-bin
    pkgs.bruno
    pkgs.github-desktop
    pkgs.rustdesk-flutter
    pkgs.qbittorrent
    # Moved from base DX suite
    pkgs.gnome-builder
    pkgs.podman-desktop
    pkgs.stress-ng
    pkgs.devtoolbox
    pkgs.clapgrep
  ];
}
