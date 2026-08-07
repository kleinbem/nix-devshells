{
  lib,
  pkgs,
  inputs ? { },
  ...
}:

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
      ]
    ))
    # GCP bootstrap for nix/infra/google (2026-08-07): `gcloud auth login`,
    # project/service-account setup for Terraform's own first credential,
    # then ongoing `gcloud` use for anything the `google` Terraform provider
    # doesn't cover. Scoped to this shell (not the shared default/default.nix
    # every meta-workspace inherits, incl. openwrt) since it's nix-specific
    # and a heavy package — no reason to pull it into unrelated shells.
    pkgs.google-cloud-sdk
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
