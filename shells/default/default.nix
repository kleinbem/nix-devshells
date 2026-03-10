{ pkgs, inputs, ... }:
{
  name = "meta-default";
  git-hooks.hooks = {
    nixfmt.enable = true;
    statix.enable = true;
    deadnix.enable = true;
  };
  packages = [
    pkgs.aider-chat
    pkgs.statix
    pkgs.nixfmt
    pkgs.deadnix
    pkgs.nil
    pkgs.sops
    pkgs.age
    pkgs.age-plugin-yubikey
    inputs.nixos-generators.packages.${pkgs.stdenv.hostPlatform.system}.nixos-generate
    pkgs.just
    pkgs.lazygit
    pkgs.gh
    pkgs.jq
    pkgs.ripgrep
    pkgs.fzf
    pkgs.android-tools
    pkgs.yq-go
    pkgs.colmena
    pkgs.openssl
  ];
  enterShell = ''
    echo "🤖 DevShell Loaded (Devenv)"
    unset SSH_ASKPASS_REQUIRE
    unset SSH_ASKPASS
  '';
}
