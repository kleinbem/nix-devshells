{ pkgs, ... }:
{
  # ESPHome firmware work for the Waveshare ESP32-P4 boards (Smart 86 Box,
  # 8" HMI) and anything else that lands in hass-pi's ESPHome dashboard.
  # The dashboard on hass-pi compiles and OTA-updates; this shell is for
  # the first USB flash and for working on device YAML locally. The
  # ESP32-P4's USB-JTAG shows up as /dev/ttyACM*; martin is in `dialout`.
  packages = with pkgs; [
    esphome # same major as hass-pi's device builder; pulls the esp-idf toolchain via platformio on first compile
    esptool # flash/erase/chip-id over USB, independent of ESPHome
    espflash # Rust flasher with monitor, handy for P4 bring-up
    picocom # serial console
  ];
  env = {
    DEV_SHELL_NAME = "esphome";
    STARSHIP_SHELL_SYMBOL = "📟 ";
  };
  enterShell = ''
    echo "📟 ESPHome DevShell Loaded — esphome $(esphome version 2>/dev/null | head -1)"
  '';
}
