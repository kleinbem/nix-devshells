{
  lib,
  inputs ? { },
  system ? "x86_64-linux",
  ...
}:

{
  imports = [
    ./apps.nix
    ./pentest.nix
    ./ai-dev.nix
    ./math.nix
    ./media.nix
  ];

  devenv.root = lib.mkForce "/home/martin/Develop/github.com/kleinbem/nix";

  # Don't re-declare `_module.args.inputs`/`system`: mkShell already injects
  # them, and `_module.args.system = system` is circular (infinite recursion in
  # `nix flake check` via the `availableOn system` filters).

  env = {
    DEV_SHELL_NAME = lib.mkForce "ultimate";
    STARSHIP_SHELL_SYMBOL = lib.mkForce "🌌 ";
    WORDLISTS = lib.mkForce "${inputs.nixpkgs.legacyPackages.${system}.seclists}/share/wordlists";
  };

  enterShell = "inventory";
}
