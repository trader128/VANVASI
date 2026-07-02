# VANVASI — Master Plan

**Tagline:** Monk mode for your mind.

**Platform:** iPhone first (iOS 17+)  
**Model:** Hard block + intentional unlock (breathing pause → timed access → auto re-lock)

---

## 1. Product definition

### What VANVASI is

VANVASI is a self-imposed phone lock. When **VANVASI Lock** is on:

- **Free forever:** Phone app, Messages (calls + SMS/iMessage), VANVASI itself
- **Blocked:** Every other app and website
- **Unlock:** Breathing pause → confirm → 15 min (one app) or 30 min (full access) → auto re-lock

The hook: **your phone defaults to monk mode.** Unlocking is a conscious choice, not a reflex.

### What VANVASI is not

- Not parental spyware (v1: user locks their own device only)
- Not a paywall / coin economy (removed from v1)
- Not Android (until iOS validates)

See [docs/PRODUCT.md](docs/PRODUCT.md) for competitor research and App Store positioning.

---

## 2. Core user experience

### States

| State | Phone | Messages | Other apps | Web |
|-------|-------|----------|------------|-----|
| Lock OFF | Open | Open | Open | Open |
| Lock ON | Open | Open | Shielded | Shielded |
| Temp unlock (single app) | Open | Open | That app open 15 min | Shielded |
| Temp unlock (everything) | Open | Open | All open 30 min | Open 30 min |

### Primary flows

**Enable lock**
1. Onboarding → grant Screen Time permission
2. User selects Phone + Messages + VANVASI as free apps
3. Toggle VANVASI Lock ON

**Open blocked app**
1. User taps Instagram → system shield appears
2. Shield: "Unlock with intention"
3. Tap → VANVASI opens → breathing pause → confirm unlock
4. App unshielded for 15 min → auto re-lock

**Emergency**
- Settings → End VANVASI Lock
- All shields removed immediately

---

## 3. Technology

| Component | Apple API |
|-----------|-----------|
| Authorization | FamilyControls |
| Shields | ManagedSettings + ManagedSettingsUI |
| Re-lock timer | DeviceActivity |
| UI | SwiftUI |
| Storage | SwiftData + App Groups |

All processing on-device. No backend in v1.

---

## 4. Visual design

Premium dark aesthetic inspired by Opal / One Sec:

- Void background (#0A0A0D), warm cream text, gold accent
- Serif headlines, glass cards, subtle glow
- Breathing animation on unlock confirm
- Haptic feedback on primary actions

Theme: `VANVASI/Design/VANASITheme.swift`

---

## 5. Project structure

```
VANVASI/              Main app
Shared/               Config, models, shield policy
VANVASIMonitor/       DeviceActivity re-lock
VANVASIShield/        Shield UI
VANVASIShieldAction/  Shield button → open app
VANVASIWidget/        Lock status widget
```

Generate: `./scripts/generate-xcodeproj.sh`

---

## 6. Roadmap

**v1 (current):** Lock, shields, intentional unlock, widget, onboarding  
**v1.1:** Focus streak / session stats  
**v2:** Scheduled lock windows, optional PIN  
**Later:** StoreKit monetization (if desired)
