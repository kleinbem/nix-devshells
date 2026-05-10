{
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
let
  pkgsMaster = import inputs.nixpkgs-master {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  imports = [ ./common.nix ];

  env.DEV_SHELL_NAME = lib.mkDefault "ai-dev";
  env.STARSHIP_SHELL_SYMBOL = lib.mkDefault "🤖 ";

  packages = lib.filter (pkg: lib.meta.availableOn system pkg) [
    pkgsMaster.claude-code
    pkgs.github-copilot-cli
    pkgs.gemini-cli
    pkgs.fabric-ai
    pkgs.lmstudio
    pkgs.alpaca
    (pkgs.python3Packages.llm.overridePythonAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    }))
  ];
}
