#!/usr/bin/env bash
# Generates VANVASI.xcodeproj from project.yml (requires xcodegen).
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "Installing xcodegen via Homebrew..."
  brew install xcodegen
fi

xcodegen generate
echo ""
echo "Done. Open VANVASI.xcodeproj in Xcode:"
echo "  open VANVASI.xcodeproj"
echo ""
echo "Then:"
echo "  1. Set your Development Team (Signing & Capabilities)"
echo "  2. Request Family Controls entitlement from Apple"
echo "  3. Build to a physical iPhone (not Simulator)"
