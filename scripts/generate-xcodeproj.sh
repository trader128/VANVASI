#!/usr/bin/env bash
# Generates VANVASI.xcodeproj from project.yml (requires xcodegen).
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "Installing xcodegen via Homebrew..."
  brew install xcodegen
fi

if [[ ! -f Config/Signing.xcconfig ]]; then
  cp Config/Signing.xcconfig.example Config/Signing.xcconfig
  echo "Created Config/Signing.xcconfig — add your Apple Team ID before building to device."
fi

xcodegen generate
echo ""
echo "Done. Open VANVASI.xcodeproj in Xcode:"
echo "  open VANVASI.xcodeproj"
echo ""
echo "Signing (required for iPhone):"
echo "  1. Edit Config/Signing.xcconfig → DEVELOPMENT_TEAM = YOUR10CHARID"
echo "  2. Re-run: ./scripts/generate-xcodeproj.sh"
echo "  Or in Xcode: each target → Signing & Capabilities → Team → your Apple ID"
echo ""
echo "Then build to a physical iPhone (not Simulator) for Screen Time shields."
