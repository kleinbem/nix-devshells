{ pkgs, ... }:
let
  # Composed Android SDK with emulator and system images
  androidSdk = pkgs.androidenv.composeAndroidPackages {
    cmdLineToolsVersion = "13.0";
    platformToolsVersion = "36.0.1";
    buildToolsVersions = [ "36.0.0" ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis_playstore" ];
    abiVersions = [ "x86_64" ];
    platformVersions = [ "36" ];
  };

  systemImageString = "system-images;android-36;google_apis_playstore;x86_64";
  scriptPath = ./scripts;

  # Launcher script wrappers
  launchScript = pkgs.writeShellApplication {
    name = "launch-android-daily-driver";
    runtimeInputs = [
      androidSdk.androidsdk
      pkgs.jdk
      pkgs.steam-run
      pkgs.android-tools
      pkgs.scrcpy
    ];
    text = ''
      export ANDROID_SDK_ROOT="${androidSdk.androidsdk}/libexec/android-sdk"
      export ANDROID_HOME="$ANDROID_SDK_ROOT"
      export JAVA_HOME="${pkgs.jdk}/lib/openjdk"
      export ANDROID_AVD_NAME="NixIntegratedDev"
      export ANDROID_SYSTEM_IMAGE="${systemImageString}"
      export ANDROID_EMULATOR_GPU_MODE="auto"
      export ANDROID_EMULATOR_MEMORY="4096"
      export ANDROID_EMULATOR_FLAGS=""
      ${builtins.readFile (scriptPath + "/launch-android-desktop.sh")}
    '';
  };

  launchVaultScript = pkgs.writeShellApplication {
    name = "launch-android-vault";
    runtimeInputs = [
      androidSdk.androidsdk
      pkgs.jdk
      pkgs.steam-run
      pkgs.android-tools
    ];
    text = ''
      export ANDROID_SDK_ROOT="${androidSdk.androidsdk}/libexec/android-sdk"
      export ANDROID_HOME="$ANDROID_SDK_ROOT"
      export JAVA_HOME="${pkgs.jdk}/lib/openjdk"
      export ANDROID_VAULT_AVD_NAME="MySecureVault"
      export ANDROID_SYSTEM_IMAGE="${systemImageString}"
      export ANDROID_EMULATOR_GPU_MODE="auto"
      export ANDROID_EMULATOR_MEMORY="4096"
      export ANDROID_EMULATOR_FLAGS=""
      ${builtins.readFile (scriptPath + "/launch-vault.sh")}
    '';
  };

  emulatorDaemonScript = pkgs.writeShellApplication {
    name = "launch-emulator-daemon";
    runtimeInputs = [
      androidSdk.androidsdk
      pkgs.jdk
      pkgs.procps
      pkgs.steam-run
      pkgs.qemu_kvm
    ];
    text = ''
      export ANDROID_SDK_ROOT="${androidSdk.androidsdk}/libexec/android-sdk"
      export ANDROID_HOME="$ANDROID_SDK_ROOT"
      export JAVA_HOME="${pkgs.jdk}/lib/openjdk"

      # Runtime Config
      export ANDROID_EMULATOR_GPU_MODE="auto"
      export ANDROID_EMULATOR_MEMORY="4096"
      export ANDROID_EMULATOR_FLAGS=""
      export ANDROID_EMULATOR_HEADLESS="true"

      # Launch the daemon script
      ${builtins.readFile (scriptPath + "/launch-emulator-daemon.sh")} "$@"
    '';
  };

  scrcpyClient = pkgs.writeShellApplication {
    name = "launch-scrcpy-client";
    runtimeInputs = [
      pkgs.android-tools
      pkgs.scrcpy
    ];
    text = ''
      ${builtins.readFile (scriptPath + "/launch-scrcpy-client.sh")} "$@"
    '';
  };

  simulateFingerprintScript = pkgs.writeShellScriptBin "simulate-fingerprint" ''
    ${builtins.readFile (scriptPath + "/simulate-fingerprint.sh")}
  '';

in
{
  packages = [
    # Android SDK & Base Tools
    androidSdk.androidsdk
    pkgs.android-tools
    pkgs.heimdall
    pkgs.scrcpy
    pkgs.jdk17
    pkgs.gradle

    # Launcher Wrappers
    launchScript
    launchVaultScript
    emulatorDaemonScript
    scrcpyClient
    simulateFingerprintScript

    # Audio/Video Support
    pkgs.alsa-utils
    pkgs.v4l-utils
    pkgs.steam-run
  ];

  env = {
    JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
    ANDROID_SDK_ROOT = "${androidSdk.androidsdk}/libexec/android-sdk";
    ANDROID_HOME = "${androidSdk.androidsdk}/libexec/android-sdk";
  };

  enterShell = ''
    echo "🤖 Android DevShell Loaded with Emulator Support"
    echo "ADB: $(adb --version | head -n 1)"
    echo "Java: $(java -version 2>&1 | head -n 1)"
    echo "Available Commands:"
    echo "  launch-android-daily-driver  - Start emulator + scrcpy client"
    echo "  launch-android-vault         - Start vault emulator"
    echo "  launch-emulator-daemon       - Run emulator headless in background"
    echo "  launch-scrcpy-client         - Attach scrcpy client to running emulator"
    echo "  simulate-fingerprint         - Simulate biometric touch"
  '';
}
