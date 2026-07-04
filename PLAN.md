# VANVASI — Master Plan

**Tagline:** Monk mode for your mind.

**Platform:** iPhone first (iOS 17+)  
**Model:** Hard block + intentional unlock (breathing pause → timed access → auto re-lock)

See **[STATUS.md](STATUS.md)** for what's shipped vs. manual steps.

---

## Shipped (all 5 phases)

| Phase | Features |
|-------|----------|
| **1 — Validate** | Shield token fix, widget refresh, lock events, device checklist |
| **2 — Polish** | Focus score/streak, session history, launch screen, app icon slot, haptics |
| **3 — Features** | Scheduled lock, PIN, Shortcuts intents, Focus via Shortcuts |
| **4 — App Store** | Privacy policy, privacy manifest, listing draft, TestFlight checklist |
| **5 — Payments** | StoreKit 2 (optional toggle in Settings, off by default) |

---

## Core experience

When **VANVASI Lock** is on: Phone + Messages + VANVASI stay free; everything else shielded.

Unlock: breathing pause → confirm → 15 min (app) / 30 min (all) → auto re-lock.

---

## Tech stack

SwiftUI · FamilyControls · ManagedSettings · DeviceActivity · SwiftData · WidgetKit · App Intents · StoreKit 2 (optional)

---

## Manual steps before App Store

1. Test on physical iPhone (`./scripts/device-test-checklist.sh`)
2. Add 1024×1024 PNG to `VANVASI/Resources/Assets.xcassets/AppIcon.appiconset/`
3. Request Family Controls entitlement from Apple
4. Archive → TestFlight → App Store Connect
5. Create IAP products if enabling paid unlocks

---

## Future (post-launch)

- Android port
- Social focus sessions
- Soundscapes during lock
- Apple Watch complication
