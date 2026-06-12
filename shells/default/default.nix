{ pkgs, inputs, ... }:
{
  name = "meta-default";
  git-hooks.package =
    (pkgs.writeShellScriptBin "prek" ''
      cmd="$1"
      if [ "$cmd" = "install" ]; then
        shift
        exec ${pkgs.prek}/bin/prek install --allow-missing-config "$@"
      else
        exec ${pkgs.prek}/bin/prek "$@"
      fi
    '')
    // {
      pname = "prek";
    };
  git-hooks.hooks = {
    # Nix
    nixfmt.enable = true;
    statix.enable = true;
    deadnix.enable = true;
    # Python — ruff (lint + format), and the parser regression suite.
    ruff.enable = true;
    ruff-format.enable = true;
    # Go
    gofmt.enable = true;
    golangci-lint.enable = true;
    pytest-nix-options = {
      enable = true;
      name = "pytest (_nix_options.py parsers)";
      entry = "${pkgs.python3Packages.pytest}/bin/pytest nix-config/scripts/tests/ -q";
      pass_filenames = false;
      files = "\\.(py|nix)$";
      language = "system";
      stages = [ "pre-commit" ];
    };
  };
  packages = [
    (pkgs.aider-chat.overridePythonAttrs (_: {
      doCheck = false;
    }))
    pkgs.nix-doc
    pkgs.statix
    pkgs.nixfmt
    pkgs.deadnix
    pkgs.nil
    pkgs.sops
    pkgs.age
    pkgs.age-plugin-yubikey
    inputs.nixos-generators.packages.${pkgs.stdenv.hostPlatform.system}.nixos-generate
    pkgs.just
    pkgs.opentofu
    pkgs.lazygit
    pkgs.gh
    pkgs.jq
    pkgs.ripgrep
    pkgs.fzf
    pkgs.android-tools
    pkgs.heimdall
    pkgs.yq-go
    pkgs.colmena
    pkgs.openssl
    pkgs.trivy
    pkgs.vulnix
    pkgs.nix-tree
    pkgs.nix-diff
  ];
  env = {
    SSH_ASKPASS = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  enterShell = ''
    echo "🤖 DevShell Loaded (Devenv)"
  '';
}
