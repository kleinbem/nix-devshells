#!/usr/bin/env bash
# Scrcpy Client - Connects to the running Daemon
# Usage: launch-scrcpy-client

ADB_SERIAL="${ANDROID_ADB_SERIAL:-emulator-5554}"

echo "🖥️ Connecting to Integrated Android..."

# Check if device is connected
if ! adb devices | awk -v s="$ADB_SERIAL" '$1 == s && $2 == "device" { f = 1 } END { exit !f }'; then
  echo "❌ Error: Emulator is not running or not ready."
  echo "Start it first: launch-emulator-daemon"
  exit 1
fi

# Launch scrcpy
scrcpy --serial "$ADB_SERIAL" \
  --window-title "Integrated Android (Zotac)" \
  --always-on-top \
  --stay-awake \
  --shortcut-mod=lctrl,lalt \
  --mouse-bind=++++ \
  "$@"
