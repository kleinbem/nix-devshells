#!/usr/bin/env bash
# Emulator Daemon - running as Systemd Service
# Usage: launch-emulator-daemon

AVD_NAME="${ANDROID_AVD_NAME:-NixIntegratedDev}"
SYSTEM_IMAGE="${ANDROID_SYSTEM_IMAGE:-system-images;android-36;google_apis_playstore;x86_64}"
ADB_SERIAL="${ANDROID_ADB_SERIAL:-emulator-5554}"
TIMEOUT=300

# Argument Parsing
if [[ $* == *"--rootable"* ]]; then
  AVD_NAME="NixIntegratedRoot"
  SYSTEM_IMAGE="system-images;android-36;google_apis;x86_64"
  echo "🔓 MODE: Rootable (Google APIs) - No Play Store"
else
  echo "🔒 MODE: Standard (Play Store) - Default"
fi

echo "🚀 Starting Emulator Daemon: $AVD_NAME"

# 1. Create AVD if needed
if ! avdmanager list avd -c | grep -Fxq -- "$AVD_NAME"; then
  echo "Creating AVD: $AVD_NAME using $SYSTEM_IMAGE"
  echo "no" | avdmanager create avd -n "$AVD_NAME" -k "$SYSTEM_IMAGE" --force
else
  echo "AVD $AVD_NAME exists."
fi

# 2. Launch Emulator (Headless, Backgrounded within script)
# We run it in background so we can run post-launch setup commands in this script.
# We will 'wait' for it at the end to keep the script (and systemd service) alive.
# Runtime Config
GPU_MODE="${ANDROID_EMULATOR_GPU_MODE:-swiftshader_indirect}"
MEMORY_SIZE="${ANDROID_EMULATOR_MEMORY:-4096}"
EXTRA_FLAGS="${ANDROID_EMULATOR_FLAGS:-}"
HEADLESS="${ANDROID_EMULATOR_HEADLESS:-true}"

# no-link: Vulkan, clipboard sharing and the qemu -m override are setup
# choices for a headless daemon, not workarounds for a reported bug.
ARGS=(
  "@$AVD_NAME"
  -no-audio
  -gpu "$GPU_MODE"
  -feature -Vulkan
  -no-snapshot-load
  -memory "$MEMORY_SIZE"
  -feature -ClipboardSharing
  -qemu -m "$MEMORY_SIZE"
)

if [ "$HEADLESS" = "true" ]; then
  ARGS+=("-no-window")
fi

echo "Starting Emulator process..."
read -ra EXTRA_ARGS <<<"${EXTRA_FLAGS//$'\n'/ }"
steam-run emulator "${ARGS[@]}" "${EXTRA_ARGS[@]}" &

EMULATOR_PID=$!

# Stop the emulator on EXIT. Signals exit so EXIT runs it; it can run after
# the emulator is already gone.
cleanup() {
  echo "Shutting down emulator..."
  kill "$EMULATOR_PID" 2>/dev/null || true
  wait "$EMULATOR_PID" 2>/dev/null || true
}
trap cleanup EXIT
trap 'exit 130' SIGINT
trap 'exit 143' SIGTERM

# 3. Wait for boot. Polls instead of `adb wait-for-device`, which blocks with
# no timeout and keeps the traps from running until adb returns.
echo "⏳ Waiting for $ADB_SERIAL to boot (sys.boot_completed)..."
ITER=0
until [ "$(timeout 10 adb -s "$ADB_SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
  if ! kill -0 "$EMULATOR_PID" 2>/dev/null; then
    echo "❌ Emulator exited before $ADB_SERIAL booted."
    exit 1
  fi
  sleep 2
  ITER=$((ITER + 2))
  if [ "$ITER" -gt "$TIMEOUT" ]; then
    echo "❌ Timeout: Android failed to boot within $TIMEOUT seconds."
    exit 1
  fi
done
echo "✅ Android Booted Successfully!"

# 4. Apply Settings
echo "⚙️ Applying persistent settings..."
# Prevent screen off and keep awake on power
adb -s "$ADB_SERIAL" shell settings put system screen_off_timeout 2147483647
adb -s "$ADB_SERIAL" shell settings put global stay_on_while_plugged_in 7

echo "✅ Daemon Ready. Listening for clients..."

# 5. Block until emulator exits
wait "$EMULATOR_PID"
