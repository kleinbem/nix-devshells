{ pkgs, inputs, ... }:
{
  name = "meta-default";
  git-hooks.package =
    (pkgs.writeShellScriptBin "prek" ''
      cmd="$1"
      if [ "$cmd" = "install" ]; then
        shift
        ${pkgs.prek}/bin/prek install --allow-missing-config "$@"
        
        # Auto-install into submodules so their hooks don't point to GC'd store paths
        if [ -d .git/modules ]; then
          for mod in .git/modules/*; do
            mod_name=$(basename "$mod")
            if [ -f "$mod_name/.pre-commit-config.yaml" ]; then
              (cd "$mod_name" && ${pkgs.prek}/bin/prek install --allow-missing-config "$@" >/dev/null 2>&1 || true)
            fi
          done
        fi
        exit 0
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
    golangci-lint.enable = false;
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
    # VCS — jj is the primary verb in this workspace (see .just/jj.just).
    # lazygit + gh kept for git operations jj doesn't cover (submodule
    # pointer bumps in meta, PR/issue UX).
    pkgs.jujutsu
    pkgs.lazyjj # lazygit-style TUI for jj
    pkgs.lazygit
    pkgs.gh
    pkgs.gh-dash # TUI dashboard for PRs/issues across repos
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

    # jj-first guard: this is a jj workspace (see .just/jj.just). Intercept the
    # mutating git verbs that jj should own so an absent-minded `git commit`/
    # `git push` doesn't bypass the jj history. Read-only git (status/log/diff),
    # `git fetch`, and jj's own libgit2 calls are untouched — jj is a separate
    # binary, not this function. One-off escape hatch: ALLOW_GIT=1 git <cmd>.
    git() {
      if [ -n "''${ALLOW_GIT:-}" ]; then command git "$@"; return; fi
      case "''${1:-}" in
        commit | push | pull | merge | rebase | reset | checkout | switch | cherry-pick | stash | am | revert)
          echo "✋ jj-first workspace — use jj instead of 'git $1'." >&2
          echo "   e.g.  git pull→jj git fetch ;  commit→jj commit ;  push→jj git push ;  checkout→jj new/edit" >&2
          echo "   bypass once:  ALLOW_GIT=1 git $*" >&2
          return 1
          ;;
        *) command git "$@" ;;
      esac
    }
  '';
}
