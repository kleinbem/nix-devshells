# Oh My Pi (omp, github.com/can1357/oh-my-pi): terminal coding-agent CLI,
# from the prebuilt release binaries; hashes in ./versions.json
# (`nix hash file --sri <url>`). A hand-kept copy of nix-packages/pkgs/oh-my-pi,
# because nix-packages already takes nix-devshells as an input.
#
# A `bun build --compile` binary. Its app payload sits in a `.bun` ELF
# section (oven-sh/bun#26923), so patchelf keeps it intact. The install check
# fails if omp ever falls back to plain bun.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  versionCheckHook,
}:
let
  pname = "oh-my-pi";
  version = "17.2.9";
  inherit (stdenv.hostPlatform) system;

  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  manifest = versions.${version}.${system} or (throw "Unsupported system for oh-my-pi: ${system}");
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit (manifest) url;
    inherit (manifest) hash;
  };

  # Not an archive — the release asset IS the binary.
  dontUnpack = true;
  # Strip still loses the payload: omp runs as plain bun.
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/omp
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = with lib; {
    description = "Terminal coding-agent CLI — IDE capabilities (LSP, Python/JS execution, browser, subagents) wired into a single terminal tool";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "omp";
  };
}
