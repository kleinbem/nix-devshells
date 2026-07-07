{
  lib,
  pkgs,
  inputs ? { },
  ...
}:

{
  imports = [ ./default/default.nix ];

  # Devenv root is the openwrt meta-workspace dir (sibling of the nix
  # meta-workspace). Loaded via `use flake ../nix/nix-devshells#openwrt`
  # from the openwrt meta root. mkForce because mkShell already sets
  # devenv.root.
  devenv.root = lib.mkForce "/home/martin/Develop/github.com/kleinbem/openwrt";

  env = {
    DEV_SHELL_NAME = "openwrt";
    NIXPKGS_ALLOW_UNFREE = "1";
    STARSHIP_SHELL_SYMBOL = "🌐 ";
  };

  _module.args.inputs = inputs;

  git-hooks.hooks = {
    # Inherited from default/default.nix but targets nix-config/scripts/tests/,
    # which only exists in the nix meta-workspace.
    pytest-nix-options.enable = lib.mkForce false;
    # Meta-root guards (sub-repos are covered by `just maintenance::lint-all`).
    shellcheck.enable = true;
    yamllint.enable = true;
  };

  packages = with pkgs; [
    # Workspace TUI (jj recipes use gum tables/spinners)
    gum

    # Configuration management
    ansible
    ansible-lint
    sshpass

    # Secrets
    sops
    age
    ssh-to-age

    # Lint / format (consumed by `just maintenance::lint-all` + pre-commit)
    shellcheck
    yamllint
    nixfmt

    # Utilities
    jq
    tree
  ];

  enterShell = ''
    echo "🌐 OpenWrt Meta-Workspace Environment Loaded"
    echo "👉 Run 'just' to open the workspace hub"
  '';
}
