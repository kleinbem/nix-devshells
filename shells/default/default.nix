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
    pkgs.nix-doc
    pkgs.statix
    pkgs.nixfmt-rfc-style
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
    SSH_ASKPASS = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  enterShell = ''
    echo "🤖 DevShell Loaded (Devenv)"
  '';
}
