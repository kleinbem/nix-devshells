#!/usr/bin/env bash
# Simulates a fingerprint touch on the Android Emulator
# Usage: simulate-fingerprint [finger_id]  (target: $ANDROID_ADB_SERIAL, default emulator-5554)
FINGER_ID="${1:-1}"
ADB_SERIAL="${ANDROID_ADB_SERIAL:-emulator-5554}"
echo "👆 Simulating Fingerprint Touch (ID: $FINGER_ID)..."
adb -s "$ADB_SERIAL" emu finger touch "$FINGER_ID"
echo "✅ Done."
