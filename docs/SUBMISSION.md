# App Store Connect — Submission Guide

Complete checklist to submit **VANVASI** v1.0.0.

**Bundle ID:** `com.vanasi.app`  
**Team ID:** `259R8YNA9M`  
**Min iOS:** 17.0  
**Category:** Productivity

---

## Phase 0 — Before you start (critical)

### 1. Apple Developer Program ($99/year)
You need an active membership at [developer.apple.com](https://developer.apple.com).

### 2. Family Controls entitlement (required — apply early)
VANVASI **will be rejected** without this.

1. Go to [Family Controls distribution request](https://developer.apple.com/contact/request/family-controls-distribution)
2. Explain:
   - **App name:** VANVASI
   - **Bundle ID:** com.vanasi.app
   - **Use case:** Adult self-imposed digital wellbeing. User locks their own iPhone to calls/messages. Not parental spyware.
3. Wait for approval (can take **days to weeks**)
4. After approval, confirm **Family Controls** appears in Xcode → VANVASI target → Signing & Capabilities

### 3. App icon (1024×1024 PNG, no transparency)
Xcode will block upload without it.

1. Create or export a **1024×1024** PNG (black background, minimal lock/leaf mark)
2. Save to:
   ```
   VANVASI/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
   ```
3. Update `Contents.json` — add `"filename": "AppIcon-1024.png"` to the 1024 entry
4. Or run: `bash scripts/prepare-app-store.sh`

---

## Phase 1 — Pre-flight in Xcode

```bash
cd ~/Projects/VANVASI
bash ./scripts/generate-xcodeproj.sh
open VANVASI.xcodeproj
```

### Checklist

- [ ] **All 5 targets** signed with Team `259R8YNA9M`
- [ ] **Release** scheme selected for archive (Product → Scheme → Edit Scheme → Archive → Release)
- [ ] Version **1.0.0** (1) in project settings
- [ ] Test on **physical iPhone** one last time
- [ ] **Pay to unlock** is OFF in Settings (unless IAP products exist in App Store Connect)
- [ ] App icon shows in Xcode asset catalog

### Device test (5 min)

1. Onboarding → Phone + Messages + **VANVASI** selected  
2. Tap ring → monk mode ON  
3. Open blocked app → shield → unlock flow  
4. Settings → End lock works  

---

## Phase 2 — Create app in App Store Connect

1. Open [App Store Connect](https://appstoreconnect.apple.com)
2. **Apps** → **+** → **New App**
3. Fill in:

| Field | Value |
|-------|--------|
| Platform | iOS |
| Name | VANVASI |
| Primary Language | English (U.S.) |
| Bundle ID | com.vanasi.app |
| SKU | vanasi-ios-001 (any unique string) |
| User Access | Full Access |

---

## Phase 3 — App Information

### Privacy Policy URL (required)

Pages live in **`docs/`** — enable GitHub Pages (branch `main` or `master`, folder **`/docs`**).

| Purpose | URL |
|---------|-----|
| Privacy Policy | `https://YOUR_USERNAME.github.io/VANVASI/privacy.html` |
| Support | `https://YOUR_USERNAME.github.io/VANVASI/support.html` |
| Marketing (optional) | `https://YOUR_USERNAME.github.io/VANVASI/` |

Setup: [GITHUB_PAGES.md](GITHUB_PAGES.md)

### Support URL (required)

Use **`support.html`** URL above (`mailto:` is not accepted).

### Category
- **Primary:** Productivity  
- **Secondary:** Health & Fitness (optional)

---

## Phase 4 — Pricing & Availability

- **Price:** Free  
- **Availability:** All countries (or pick your markets)

---

## Phase 5 — App Privacy (nutrition labels)

In App Store Connect → **App Privacy**:

**Do you collect data?** → **No, we do not collect data from this app**

(VANVASI stores everything on-device; no analytics SDKs.)

If asked about UserDefaults in privacy manifest — already declared in `PrivacyInfo.xcprivacy` (CA92.1, app functionality only).

---

## Phase 6 — Age Rating

Complete the questionnaire. Expected result: **4+**

Typical answers for VANVASI:
- No violence, gambling, unrestricted web (app blocks web when locked)
- No user-generated content
- Not designed for children under 13 as primary audience

---

## Phase 7 — Version 1.0.0 listing copy

Copy from [APP_STORE.md](APP_STORE.md) or use below:

**Subtitle (30 chars max):**  
`Monk mode for your mind`

**Promotional text (170 chars):**  
`Lock your phone to calls and texts. Unlock with intention — not impulse.`

**Description:** See [APP_STORE.md](APP_STORE.md) — full text ready to paste.

**Keywords (100 chars, comma-separated, no spaces after commas):**  
`screen time,focus,app blocker,digital wellbeing,monk mode,distraction,phone lock`

**What's New:**  
`Initial release. Monk mode for your iPhone — calls and messages only, unlock with intention.`

---

## Phase 8 — Screenshots

Required: **6.7" iPhone** (iPhone 15 Pro Max / 16 Pro Max size) — at least **3** screenshots.

Capture on your iPhone or Simulator (iPhone 16 Pro Max):

| # | Screen | How to capture |
|---|--------|----------------|
| 1 | Home — monk mode ON (black, lock ring) | Lock enabled |
| 2 | Unlock — "Pause." breathing screen | Tap Request access |
| 3 | Onboarding — "Monk mode for your mind" | Reset onboarding or new install |
| 4 | Shield — blocked app | Open Instagram while locked |
| 5 | Settings — minimal list | Tap ⋯ |
| 6 | Widget (optional) | Add widget to home screen |

**Sizes:** 1290 × 2796 px (6.7" display) — Xcode Simulator → Cmd+S, or iPhone screenshot.

---

## Phase 9 — Optional: In-App Purchases

**Skip for v1** if "Pay to unlock" stays OFF in the app.

If you enable payments later, create in App Store Connect → **In-App Purchases**:

| Product ID | Type | Reference name |
|------------|------|----------------|
| `com.vanasi.unlock.app` | Consumable | Unlock one app (15 min) |
| `com.vanasi.unlock.all` | Consumable | Unlock all (30 min) |

Set prices in App Store Connect. Submit IAPs with the app version.

---

## Phase 10 — Archive & upload

### In Xcode

1. Select **Any iOS Device (arm64)** as destination (not Simulator)
2. **Product → Archive**
3. When Organizer opens → **Distribute App**
4. **App Store Connect** → **Upload**
5. Keep defaults: Include bitcode off, Upload symbols **yes**, Manage version automatically **yes**
6. Wait for processing (10–30 min)

### Export compliance
When prompted in Xcode: **No** — app uses only standard HTTPS / no custom encryption  
(Already set: `ITSAppUsesNonExemptEncryption = false`)

---

## Phase 11 — Submit for review

In App Store Connect → your app → **1.0.0 Prepare for Submission**:

- [ ] Build selected (appears after processing)
- [ ] Screenshots uploaded
- [ ] Description, keywords, subtitle filled
- [ ] Privacy policy URL set
- [ ] Support URL set
- [ ] Age rating complete
- [ ] App Privacy complete

### Review notes (paste into "Notes for Review")

```
VANVASI is a self-imposed digital wellbeing app for adults.

HOW TO TEST:
1. Complete onboarding — grant Screen Time (Family Controls) permission when prompted.
2. On "Free apps" step, select Phone, Messages, and VANVASI (required so user is not locked out).
3. Tap the lock ring on home screen to enable "Monk mode."
4. Leave the app and open any other app (e.g. Safari) — a shield appears.
5. Tap "Unlock" on shield → open VANVASI from notification → complete "Pause." flow.
6. To disable: tap ⋯ (top right) → End lock.

FAMILY CONTROLS:
This app uses Apple's Family Controls API for app shielding. Entitlement: com.apple.developer.family-controls.
The user locks their own device — not parental monitoring.

EMERGENCY EXIT:
Settings (⋯) → End lock. Optional PIN can be enabled by user.

DEMO ACCOUNT: Not required — no login.

CONTACT: support@vanasi.app
```

Click **Add for Review**.

Review typically takes **24–48 hours** (longer if Family Controls is questioned).

---

## Phase 12 — After submission

| Status | Action |
|--------|--------|
| **Waiting for Review** | Wait |
| **In Review** | Monitor email |
| **Rejected** | Read Resolution Center → fix → resubmit |
| **Approved** | Release manually or auto |

Common rejection reasons for Screen Time apps:
- Family Controls entitlement not approved
- Reviewer locked themselves out (notes must say select VANVASI in allowlist)
- Missing privacy policy URL

---

## Quick reference

| Item | Value |
|------|--------|
| App name | VANVASI |
| Bundle ID | com.vanasi.app |
| Version | 1.0.0 (1) |
| Team | 259R8YNA9M |
| Entitlement | Family Controls + App Groups |
| App Group | group.com.vanasi.shared |
| Privacy manifest | VANVASI/PrivacyInfo.xcprivacy |
| Privacy / support site | `docs/` → GitHub Pages |
| App icon | `VANVASI/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` |

---

## Commands cheat sheet

```bash
# Regenerate project
bash ./scripts/generate-xcodeproj.sh

# Pre-flight checks
bash ./scripts/prepare-app-store.sh

# Device QA
bash ./scripts/device-test-checklist.sh
```

---

## Recommended order (timeline)

| Day | Task |
|-----|------|
| **Today** | Apply Family Controls entitlement if not approved |
| **Today** | Add 1024 app icon |
| **Today** | Host privacy policy URL |
| **Tomorrow** | Screenshots + App Store Connect listing |
| **Tomorrow** | Archive & upload build |
| **Day 3** | Submit for review |

Good luck — you're close.
