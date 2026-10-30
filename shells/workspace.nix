{
  lib,
  pkgs,
  inputs ? { },
  ...
}:

let
  # Expose just the named binaries of a package that also ships a server.
  clisOf =
    pkg: bins:
    pkgs.runCommand "${pkg.pname or pkg.name}-clis" { } ''
      mkdir -p $out/bin
      ${lib.concatMapStrings (b: "ln -s ${lib.getExe' pkg b} $out/bin/\n") bins}
    '';

  # hass-cli against hass-pi. The token (HA user `cli`) is a sops secret on
  # nixos-nvme, read per call so it never sits in the shell environment, and
  # only when the call goes to hass-pi: an explicit HASS_SERVER or --server
  # gets no token, and neither does --debug (it logs the request headers).
  # HASS_TOKEN or HASSIO_TOKEN still override.
  hass-cli = pkgs.writeShellApplication {
    name = "hass-cli";
    text = ''
      own=1
      [ -n "''${HASS_SERVER:-}" ] && own=0
      for a in "$@"; do
        case "$a" in -s | --server | --server=* | --debug) own=0 ;; esac
      done
      export HASS_SERVER="''${HASS_SERVER:-http://10.0.0.21:8123}"
      if [ "$own" = 1 ] && [ -z "''${HASS_TOKEN:-}''${HASSIO_TOKEN:-}" ] && [ -r /run/secrets/hass_cli_token ]; then
        HASS_TOKEN="$(< /run/secrets/hass_cli_token)"
        export HASS_TOKEN
      fi
      exec ${lib.getExe pkgs.home-assistant-cli} "$@"
    '';
  };
in
{
  imports = [ ./default/default.nix ];

  # Devenv root is the meta-workspace dir (parent of nix-devshells). When
  # this shell loads via `use flake ./nix-devshells#workspace` from the
  # meta root, devenv state still lives in the workspace, not under
  # nix-devshells. mkForce because mkShell already sets devenv.root.
  devenv.root = lib.mkForce "/home/martin/Develop/github.com/kleinbem/nix";

  env = {
    DEV_SHELL_NAME = "meta";
    NIXPKGS_ALLOW_UNFREE = "1";
    STARSHIP_SHELL_SYMBOL = "🏗️ ";
  };

  _module.args.inputs = inputs;

  processes.workspace-info.exec = "while true; do date; sleep 3600; done";

  scripts.workspace-status.exec = ''
    echo "🏗️  Project Root: $DEVENV_ROOT"
    echo -n "🚀 Status: "
    pushd "$DEVENV_ROOT" > /dev/null
    devenv tasks run workspace:health
    popd > /dev/null
  '';

  packages = [
    # claude-code comes from the user profile (nix-config home-manager);
    # bleeding-edge copy lives in the ai-dev shell (pkgsMaster).
    pkgs.openssh
    (pkgs.python3.withPackages (
      p: with p; [
        mcp
        psutil
        requests
        google-api-python-client
        google-auth-oauthlib
        pyyaml # nix-config/scripts/generate-infra-yaml.py (sync-agent)
      ]
    ))
    # GCP bootstrap for nix/infra/google (2026-08-07): `gcloud auth login`,
    # project/service-account setup for Terraform's own first credential,
    # then ongoing `gcloud` use for anything the `google` Terraform provider
    # doesn't cover. Scoped to this shell (not the shared default/default.nix
    # every meta-workspace inherits, incl. openwrt) since it's nix-specific
    # and a heavy package — no reason to pull it into unrelated shells.
    pkgs.google-cloud-sdk
    # Manual push/pin to the kleinbem-nixpkgs-review cache; CI pushes on its own.
    pkgs.cachix

    # One CLI per app/service the fleet runs, so agents drive them through
    # Bash instead of MCP. garage, ntfy, netbird, buzz and rbw (Vaultwarden)
    # already come from the system/user profile.
    pkgs.attic-client
    hass-cli
    pkgs.grafanactl
    pkgs.cloudflared
    pkgs.flarectl
    pkgs.wrangler # Cloudflare Pages
    pkgs.stalwart-cli
    pkgs.ente-cli
    pkgs.qbittorrent-cli # qbt
    # Server packages that ship the client: keep only the client on PATH.
    (clisOf pkgs.grafana-loki [ "logcli" ])
    (clisOf pkgs.prometheus-alertmanager [ "amtool" ])
    (clisOf pkgs.postgresql [ "psql" ]) # dev-db and service databases
    pkgs.syncthing # `syncthing cli` against a remote GUI address
    pkgs.ollama # client via OLLAMA_HOST
    pkgs.caddy # caddy validate/fmt/adapt
  ];

  tasks."workspace:health" = {
    exec = ''
      if curl -s -f http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "✅ Ollama is ONLINE"
      else
        echo "⚠️ Ollama is OFFLINE (Run 'just ai-up' to start)"
      fi
    '';
    before = [ "devenv:enterShell" ];
  };
}
