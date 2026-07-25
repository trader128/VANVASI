# TestFlight — VANVASI on your iPhone

Use this after **`master`** includes the 1.2.x build (shield → pause polish).

## One-time (App Store Connect)

1. [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **VANVASI**.
2. **TestFlight** tab → ensure the app record exists and **Family Controls** capability is enabled on the app ID in [Developer](https://developer.apple.com/account/resources/identifiers).

## Build & upload (Xcode)

```bash
cd ~/Projects/VANVASI
bash ./scripts/generate-xcodeproj.sh
open VANVASI.xcodeproj
```

1. Select **Any iOS Device (arm64)** (not Simulator).
2. **Product → Archive** (needs ~15 GB free disk).
3. **Distribute App → App Store Connect → Upload**.
4. Wait for processing (often 5–20 minutes).

## Install on your phone

1. App Store Connect → **TestFlight** → **Internal Testing** (your team) or **External** (needs brief beta review).
2. On iPhone: install **TestFlight**, accept the invite, install **VANVASI**.
3. Settings → grant **Screen Time** when VANVASI asks.

## Core loop to verify (10 minutes)

| Step | Expected |
|------|----------|
| Onboarding + free apps | Phone, Messages, VANVASI selected |
| Tap ring | Monk mode ON, merit toast optional |
| Open blocked app | Shield: **Pause.** · **Open VANVASI** / **Stay focused** |
| **Stay focused** | Shield closes; reopen VANVASI → merit toast (+30) |
| **Open VANVASI** | Notification → tap → **Pause.** screen in app |
| **Stay focused** (in app) | Closes, merit |
| **Unlock for N min** | Temp access; home shows re-lock countdown |
| Settings → End lock | Shields off, Live Activity ends |

## Notes

- Shields **do not work** in Simulator — TestFlight or USB run on device only.
- Paste `docs/REVIEW_NOTES.txt` when you submit to **App Review** (after your 5.6 cooldown plan).
- Internal TestFlight builds do not replace a store submission.
