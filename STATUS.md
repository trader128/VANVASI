# VANVASI — Project Status

**Last updated:** July 2026  
**Version:** 1.0.0

## Completed phases

### Phase 1 — Device validation ✅
- Single-app unlock stores `ApplicationToken` from shield
- Widget reload on lock state changes
- Lock events logged (enable/disable/emergency)
- Device test checklist script
- Version strings aligned across extensions

### Phase 2 — v1.1 polish ✅
- **Focus score, streak, unlock count** on home screen
- **Session history** — unlocks, lock events, payments
- **Launch screen** — dark `LaunchBackground` color
- **App icon** — gold leaf on void (`Assets.xcassets`)
- **Haptics** — success feedback on unlock

### Phase 3 — v1.2 features ✅
- **Scheduled lock** — daily window via DeviceActivity
- **PIN protection** — Keychain-backed, gates disable/end lock
- **Shortcuts** — Enable / Disable / Toggle intents
- **Focus Mode sync** — via Shortcuts automation (documented in Schedule settings)

### Phase 4 — App Store prep ✅
- `docs/PRIVACY.md` + in-app Privacy Policy view
- `PrivacyInfo.xcprivacy` privacy manifest
- `docs/APP_STORE.md` — listing draft, screenshots list
- `docs/TESTFLIGHT.md` — beta checklist

### Phase 5 — Payments (optional) ✅
- StoreKit 2 gateway restored
- Toggle **Pay to unlock** in Settings (off by default)
- `PaymentRecord` model + history section
- Product IDs: `com.vanasi.unlock.app`, `com.vanasi.unlock.all`

---

## What you must do manually

1. **Test on iPhone 12** — run `./scripts/device-test-checklist.sh`
2. **Family Controls entitlement** — Apple Developer request
3. **App Store Connect** — create app + IAP products (if payments on)
4. **TestFlight upload** — Archive in Xcode
5. **Add AppIcon-1024.png** if missing from asset catalog (1024×1024 PNG)

---

## Quick commands

```bash
cd ~/Projects/VANVASI
bash ./scripts/generate-xcodeproj.sh
open VANVASI.xcodeproj
```
