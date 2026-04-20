{ pkgs, inputs, ... }:
{
  name = "meta-default";
  git-hooks.hooks = {
    nixfmt.enable = true;
    statix.enable = true;
    deadnix.enable = true;
  };
  packages = [
    (pkgs.aider-chat.overridePythonAttrs (_: {
      doCheck = false;
    }))
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
    pkgs.trivy
    pkgs.vulnix
  ];
  env = {
    SSH_ASKPASS = "/run/current-system/sw/bin/lxqt-openssh-askpass";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  enterShell = ''
    echo "🤖 DevShell Loaded (Devenv)"
  '';
}
