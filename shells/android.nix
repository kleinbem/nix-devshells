{ pkgs, ... }: {
  packages = [
    pkgs.android-tools
    pkgs.scrcpy
    pkgs.jdk17
    pkgs.gradle
  ];

  env.JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";

  enterShell = ''
    echo "🤖 Android DevShell Loaded"
    echo "ADB: $(adb --version | head -n 1)"
    echo "Java: $(java -version 2>&1 | head -n 1)"
  '';
}
