{ pkgs, inputs, ... }: {
  name = "meta-default";
  pre-commit.hooks = {
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
    inputs.nixos-generators.packages.${pkgs.system}.nixos-generate
    pkgs.just
    pkgs.lazygit
    pkgs.gh
    pkgs.jq
    pkgs.ripgrep
    pkgs.fzf
    pkgs.android-tools
  ];
  enterShell = ''
    echo "🤖 DevShell Loaded (Devenv)"
    unset SSH_ASKPASS_REQUIRE
    unset SSH_ASKPASS
  '';
}
