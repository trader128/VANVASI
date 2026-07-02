# VANVASI — Setup Guide

## 1. Generate Xcode project

```bash
cd ~/Projects/VANVASI
brew install xcodegen   # once
./scripts/generate-xcodeproj.sh
open VANVASI.xcodeproj
```

After `xcodegen generate`, verify entitlements files still contain Family Controls + App Groups (see troubleshooting).

## 2. Xcode signing

1. Select **VANVASI** target → **Signing & Capabilities**
2. Set your **Team** (Apple Developer account)
3. Repeat for each extension target:
   - VANVASIMonitor
   - VANVASIShield
   - VANVASIShieldAction
   - VANVASIWidget

## 3. Capabilities (main app)

- **Family Controls** — request entitlement from Apple
- **App Groups** — `group.com.vanasi.shared`

## 4. Build to iPhone

Screen Time / shield APIs require a **physical device**. Simulator can launch the UI but **will not** run Family Controls shields.

1. Connect iPhone
2. Select device in Xcode (not Simulator)
3. **Run** (⌘R)
4. Complete onboarding → select **Phone + Messages + VANVASI**
5. Enable **VANVASI Lock**
6. Try opening a blocked app → shield → **Unlock with intention**

### Simulator note

If Simulator install fails on widget extensions: run `xcodegen generate` after pulling latest. For lock testing, use a real device anyway.

## 5. Family Controls entitlement

Apply at: [Apple Developer — Family Controls](https://developer.apple.com/contact/request/family-controls-distribution)

Use case: adult digital wellbeing, self-imposed app lock.

## Project config

Edit unlock durations in:

```
Shared/VANVASIConfig.swift
```

## Troubleshooting

### "Couldn't communicate with a helper application" / FamilyControlsAgent

This almost always means **Family Controls entitlement is missing** from the signed build.

**Fix in Xcode (all targets that use Screen Time):**

| Target | Capabilities needed |
|--------|---------------------|
| VANVASI | Family Controls + App Groups |
| VANVASIMonitor | Family Controls + App Groups |
| VANVASIShield | Family Controls + App Groups |
| VANVASIShieldAction | Family Controls + App Groups |
| VANVASIWidget | App Groups only |

Steps:
1. Select each target → **Signing & Capabilities** → **+ Capability** → add **Family Controls** (main + 3 shield/monitor extensions)
2. Add **App Groups** → `group.com.vanasi.shared` on all 5 targets
3. Confirm `VANVASI.entitlements` contains `com.apple.developer.family-controls` (not an empty file)
4. **Product → Clean Build Folder** (⇧⌘K)
5. Delete VANVASI from iPhone → **Run** again on **physical iPhone** (not Simulator)

**Do not run `xcodegen generate` without checking entitlements** — it can wipe `.entitlements` files. Re-run the plist restore from git if needed.

Also on iPhone: **Settings → Screen Time** should be enabled.

| Issue | Fix |
|-------|-----|
| Shield doesn't appear | Family Controls permission granted? Physical device? |
| Locked out of VANVASI | Add VANVASI to free apps list |
| Build fails on extension | Set Team on all 5 targets |
