{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./common.nix ];

  env.DEV_SHELL_NAME = lib.mkDefault "apps";
  env.STARSHIP_SHELL_SYMBOL = lib.mkDefault "🏢 ";

  packages = lib.filter (pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg) [
    pkgs.slack
    pkgs.dbeaver-bin
    pkgs.bruno
    pkgs.github-desktop
    pkgs.rustdesk-flutter
    pkgs.qbittorrent
    pkgs.ente-auth
    # Moved from base DX suite
    pkgs.gnome-builder
    pkgs.podman-desktop
    pkgs.stress-ng
    pkgs.devtoolbox
    pkgs.clapgrep
  ];
}
