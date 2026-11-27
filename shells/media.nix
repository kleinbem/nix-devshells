{ pkgs, lib, ... }:
{
  env.DEV_SHELL_NAME = lib.mkDefault "media";

  enterShell = ''
    echo "🎬 Media Production Shell Active"
    echo "   Tools: obs-studio"
  '';

  packages = [
    pkgs.obs-studio
  ];
}
