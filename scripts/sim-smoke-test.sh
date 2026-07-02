#!/usr/bin/env bash
# Build, install, and launch VANVASI on iOS Simulator for smoke testing.
set -euo pipefail
cd "$(dirname "$0")/.."

if command -v xcodegen >/dev/null 2>&1; then
  xcodegen generate || true
fi

DEST="${1:-platform=iOS Simulator,name=iPhone 17,OS=26.5}"
echo "Building for: $DEST"

xcodebuild \
  -scheme VANVASI \
  -project VANVASI.xcodeproj \
  -destination "$DEST" \
  -configuration Debug \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build

APP=$(find ~/Library/Developer/Xcode/DerivedData/VANVASI-*/Build/Products/Debug-iphonesimulator -name 'VANVASI.app' -maxdepth 1 2>/dev/null | head -1)
if [[ -z "$APP" ]]; then
  echo "Could not find VANVASI.app in DerivedData"
  exit 1
fi

echo "Installing: $APP"
xcrun simctl install booted "$APP" || xcrun simctl boot "iPhone 17" && xcrun simctl install booted "$APP"

echo "Launching com.vanasi.app"
xcrun simctl launch booted com.vanasi.app

echo "Done. Note: Family Controls / shields require a physical iPhone."
