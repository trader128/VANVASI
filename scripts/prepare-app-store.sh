#!/usr/bin/env bash
# Pre-flight checks before App Store archive.
set -euo pipefail
cd "$(dirname "$0")/.."

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok=0
warn=0
fail=0

check() {
  local label="$1"
  local result="$2"
  if [[ "$result" == "ok" ]]; then
    echo -e "${GREEN}✓${NC} $label"
    ((ok++)) || true
  elif [[ "$result" == "warn" ]]; then
    echo -e "${YELLOW}!${NC} $label"
    ((warn++)) || true
  else
    echo -e "${RED}✗${NC} $label"
    ((fail++)) || true
  fi
}

echo "VANVASI App Store pre-flight"
echo "============================"
echo ""

# App icon
ICON="VANVASI/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
if [[ -f "$ICON" ]]; then
  check "App icon 1024×1024 present" ok
else
  check "App icon 1024×1024 MISSING — add AppIcon-1024.png to AppIcon.appiconset" fail
fi

# Privacy manifest
if [[ -f "VANVASI/PrivacyInfo.xcprivacy" ]]; then
  check "Privacy manifest present" ok
else
  check "Privacy manifest missing" fail
fi

# Entitlements
for f in VANVASI/VANVASI.entitlements VANVASIMonitor/VANVASIMonitor.entitlements; do
  if [[ -s "$f" ]] && grep -q "family-controls" "$f" 2>/dev/null; then
    check "Family Controls in $(basename "$f")" ok
  else
    check "Family Controls MISSING in $f" fail
  fi
done

# Version in project.yml
if grep -q 'MARKETING_VERSION: "1.0.0"' project.yml; then
  check "Marketing version 1.0.0" ok
else
  check "Check MARKETING_VERSION in project.yml" warn
fi

# Privacy policy HTML for hosting
if [[ -f "docs/privacy-policy.html" ]]; then
  check "Privacy policy HTML ready to host" ok
else
  check "docs/privacy-policy.html missing" fail
fi

echo ""
echo "Summary: $ok passed, $warn warnings, $fail failed"
echo ""

if [[ $fail -gt 0 ]]; then
  echo "Fix failures above before archiving."
  echo "Full guide: docs/SUBMISSION.md"
  exit 1
fi

echo "Ready to archive. Next steps:"
echo "  1. Host docs/privacy-policy.html → paste URL in App Store Connect"
echo "  2. Apply/confirm Family Controls entitlement with Apple"
echo "  3. Xcode → Product → Archive → Upload"
echo "  See docs/SUBMISSION.md for full checklist."
