{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  name = "meta-default";

  # devenv's git-hooks integration adds a `devenv:git-hooks:run` task
  # (`prek run -a`). It's declared `before devenv:enterTest`, but
  # devenv-tasks runs every start-enabled task on `enterShell` too, so it
  # fires on every direnv load / `cd`. Unlike `devenv:git-hooks:install`
  # (guarded with `git rev-parse --git-dir`) the run task has no git-repo
  # guard: when this shell is entered through the deliberately-non-git meta
  # root `~/Develop/github.com/kleinbem/.envrc` (see root CLAUDE.md), `prek`
  # aborts with "fatal: not a git repository" and fails the whole direnv
  # load. Hooks are still installed as a real pre-commit hook by
  # `devenv:git-hooks:install` and run at commit time and in CI, so make
  # the shell-entry invocation a no-op.
  tasks."devenv:git-hooks:run".exec = lib.mkForce ''
    exit 0
  '';
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
      # Self-locating: this hook is installed via the shared "meta-default"
      # shell into whatever repo's .git/hooks/pre-commit invokes it, so cwd
      # varies — nix-config itself (scripts/tests is right there) vs a
      # workspace-root-style invocation where nix-config is a child dir.
      # No-op where neither exists (repos this hook doesn't apply to).
      entry = "${pkgs.writeShellScript "pytest-nix-options" ''
        if [ -d scripts/tests ]; then
          exec ${pkgs.python3Packages.pytest}/bin/pytest scripts/tests/ -q
        elif [ -d nix-config/scripts/tests ]; then
          exec ${pkgs.python3Packages.pytest}/bin/pytest nix-config/scripts/tests/ -q
        fi
      ''}";
      pass_filenames = false;
      files = "\\.(py|nix)$";
      language = "system";
      stages = [ "pre-commit" ];
    };
    version-consistency = {
      enable = true;
      name = "Check version consistency";
      description = "Warn if same version pattern appears in multiple files being committed";
      entry = "${pkgs.writeShellScript "check-version-consistency" ''
        set -e
        staged_files=$(git diff --cached --name-only 2>/dev/null || true)
        [ -z "$$staged_files" ] && exit 0

        # Extract version patterns: platformToolsVersion, androidVersion, etc.
        # Report if the same version string is being changed in multiple files
        versions=$(echo "$$staged_files" | xargs grep -h -E '\b(platformTools|android|rust|python)Version\s*=' 2>/dev/null | sed -E 's/.*\b([a-zA-Z]+Version)\s*=\s*"?([^"]+)"?.*/\1=\2/' | sort || true)

        echo "$$versions" | uniq -d | while read dup_line; do
          if [ -n "$$dup_line" ]; then
            echo "⚠️  Version drift detected: $dup_line appears in multiple staged files"
            echo "     Review your commits for consistency before pushing"
            exit 1
          fi
        done
        exit 0
      ''}";
      language = "system";
      pass_filenames = false;
      files = "\\.(nix|py)$";
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

    # Put jj-fleet (the packaged status-all/diff-all/remote-status/... subset
    # of the jj dashboard — see kleinbem/tools/jj-fleet.sh) on PATH directly,
    # so it works as a bare command from inside ANY repo in the workspace,
    # not just the three conductors that have a justfile wired to it. Finds
    # the workspace root by walking up from $PWD looking for
    # kleinbem/repos.nix (same marker jj-fleet.sh itself uses) — computed
    # here at shell-start, not baked in as a flake input, specifically so
    # this file stays identical across every machine/checkout location.
    # Fails silently if not inside the workspace (e.g. this devshell reused
    # by an unrelated project).
    _jjfleet_root() {
      local dir="$PWD"
      while [ "$dir" != "/" ]; do
        [ -f "$dir/kleinbem/repos.nix" ] && { printf '%s\n' "$dir"; return 0; }
        dir="$(dirname "$dir")"
      done
      return 1
    }
    if _jjfleet_root_dir=$(_jjfleet_root) \
      && _jjfleet_bin=$(nix build --no-link --print-out-paths "$_jjfleet_root_dir/kleinbem#jj-fleet" 2>/dev/null); then
      export PATH="$_jjfleet_bin/bin:$PATH"
    fi
    unset -f _jjfleet_root

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
