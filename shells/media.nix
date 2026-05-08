{ pkgs, ... }:
{
  env.DEV_SHELL_NAME = "media";

  enterShell = ''
    echo "🎬 Media Production Shell Active"
    echo "   Tools: obs-studio"
  '';

  packages = [
    pkgs.obs-studio
  ];
}
