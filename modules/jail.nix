{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.jail;
in
{
  options.my.jail = {
    enable = lib.mkEnableOption "Bubblewrap Jailing for DevShells";

    blackhole = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        ".ssh"
        ".gnupg"
        ".aws"
        ".config/sops"
        ".config/gcloud"
        ".config/exercism"
        ".config/gh"
      ];
      description = "Paths in $HOME to blackhole (mount as empty tempfs)";
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [ pkgs.bubblewrap ];

    scripts.jail-exec.exec = ''
      # Helper script to run commands inside a bubblewrap jail

      # Determine project root (devenv sets this)
      PROJECT_ROOT="''${DEVENV_ROOT:-$(pwd)}"

      # Build the bwrap command
      BWRAP_ARGS=(
        --ro-bind /nix/store /nix/store
        --ro-bind /etc /etc
        --dev /dev
        --proc /proc
        --tmpfs /tmp
        --tmpfs /run
        --bind "$HOME" "$HOME"
        --bind "$PROJECT_ROOT" "$PROJECT_ROOT"
        --chdir "$(pwd)"
        --unshare-all
        --share-net
        --hostname agent-sanctuary
      )

      # Blackhole sensitive paths in HOME
      for path in ${lib.escapeShellArgs cfg.blackhole}; do
        # Only blackhole if the directory exists to avoid bwrap errors
        if [ -d "$HOME/$path" ]; then
          BWRAP_ARGS+=(--tmpfs "$HOME/$path")
        elif [ -f "$HOME/$path" ]; then
           # For files, we can mount an empty file or just skip
           # tmpfs on a file path might fail depending on kernel/bwrap version
           # Safer to just skip if it's not a dir, or use --bind /dev/null
           BWRAP_ARGS+=(--bind /dev/null "$HOME/$path")
        fi
      done

      # Execute the command
      exec ${pkgs.bubblewrap}/bin/bwrap "''${BWRAP_ARGS[@]}" "$@"
    '';
  };
}
