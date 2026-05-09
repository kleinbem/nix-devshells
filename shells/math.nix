{ pkgs, lib, ... }:
{
  imports = [ ./common.nix ];

  env.DEV_SHELL_NAME = lib.mkDefault "math";
  env.STARSHIP_SHELL_SYMBOL = lib.mkDefault "🧮 ";

  packages = [
    pkgs.octaveFull
    pkgs.typst
    pkgs.tinymist
  ];
}
