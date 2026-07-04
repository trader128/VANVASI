#!/usr/bin/env bash
# Device test checklist runner — prints steps; run on physical iPhone via Xcode.
set -euo pipefail

echo "VANVASI Device Test Checklist"
echo "=============================="
echo ""
echo "Prerequisites:"
echo "  • iPhone connected, VANVASI installed from Xcode"
echo "  • Screen Time permission granted"
echo "  • Phone + Messages + VANVASI in free apps list"
echo ""
steps=(
  "Launch app → complete or skip onboarding"
  "Toggle VANVASI Lock ON → confirm shield active"
  "Open a blocked app (e.g. Safari) → shield appears"
  "Tap 'Unlock with intention' → notification → open VANVASI"
  "Complete breathing pause → confirm unlock"
  "Verify app opens; home shows countdown"
  "Wait or fast-forward time → lock restores"
  "Settings → Scheduled lock → set window → verify"
  "Settings → PIN protection → set PIN"
  "Try disabling lock → PIN required"
  "Settings → History → sessions listed"
  "Home screen widget → shows Monk mode status"
  "Shortcuts app → run 'Enable VANVASI Lock'"
)
i=1
for step in "${steps[@]}"; do
  echo "  $i. [ ] $step"
  ((i++)) || true
done
echo ""
echo "Mark each step manually after testing on device."
