# Oh My Pi (omp, github.com/can1357/oh-my-pi): terminal coding-agent CLI,
# from the prebuilt release binaries; hashes in ./versions.json
# (`nix hash file --sri <url>`). A hand-kept copy of nix-packages/pkgs/oh-my-pi,
# because nix-packages already takes nix-devshells as an input.
#
# No patchelf: it's a `bun build --compile` binary whose payload sits at a fixed
# offset from EOF, and growing the file makes it fall back to plain bun. So the
# binary stays byte-for-byte and the wrapper runs it through the dynamic linker.
# upstream: oven-sh/bun#4103, fixed by oven-sh/bun#26923 (payload in an ELF
# section). Try patchelf again once omp ships a binary built with that bun.
{
  lib,
  stdenv,
  fetchurl,
  glibc,
  makeWrapper,
}:
let
  pname = "oh-my-pi";
  version = "17.2.9";
  inherit (stdenv.hostPlatform) system;

  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  manifest = versions.${version}.${system} or (throw "Unsupported system for oh-my-pi: ${system}");

  dynamicLinker =
    {
      x86_64-linux = "ld-linux-x86-64.so.2";
      aarch64-linux = "ld-linux-aarch64.so.1";
    }
    .${system} or (throw "Unsupported system for oh-my-pi: ${system}");
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit (manifest) url;
    inherit (manifest) hash;
  };

  # Not an archive — the release asset IS the binary.
  dontUnpack = true;
  # Stripping alone also breaks the embedded payload (see top of file).
  dontStrip = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec
    # Untouched, byte-for-byte as downloaded — see the top-of-file comment
    # for why this must NOT go through patchelf.
    install -m755 $src $out/libexec/omp-unwrapped

    makeWrapper "${glibc}/lib/${dynamicLinker}" $out/bin/omp \
      --add-flags "--library-path ${glibc}/lib" \
      --add-flags "$out/libexec/omp-unwrapped"

    runHook postInstall
  '';

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
