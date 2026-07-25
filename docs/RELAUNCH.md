# VANVASI — Relaunch guide (v1.2.0)

After Guideline **5.6** suspension, do **not** resubmit 1.0 unchanged. Ship **1.2.0** (substantial update over 1.0), wait at least **30 days** from the suspension date if possible, then submit a **new version** with detailed review notes.

## What changed in 1.2.0

- **Merit points** — levels, progress, home card, widget, Settings → Merit guide
- **Live Activity** — monk mode / unlock countdown on Lock Screen & Dynamic Island
- UI motion, haptics, scrollable home layout (from branch polish)
- Everything in 1.1.0 below
- Version **1.2.0 (5)**

## What changed in 1.1.0

- 4-step onboarding with “How it works”
- Settings → **How it works** guide (matches Review Notes)
- Shield shows lock icon (not blank)
- History empty states
- **Pay to unlock** hidden (`VANVASIConfig.showPaymentsInSettings = false`)
- Footer: “Self-imposed focus lock · Not parental controls”
- Version **1.1.0 (4)**

## App Store Connect (before submit)

| Item | Value |
|------|--------|
| Price | **Free** or deliberate **$9.99** — never accidental tier |
| Age rating | Parental Controls → **None** |
| Privacy URL | https://trader128.github.io/VANVASI/privacy.html |
| Support URL | https://trader128.github.io/VANVASI/support.html |

## Review notes (paste)

See `docs/REVIEW_NOTES.txt` — emphasize adult self-lock, not parental controls, emergency exit via Settings.

## Build

```bash
cd ~/Projects/VANVASI
bash ./scripts/generate-xcodeproj.sh
# Archive → Upload 1.2.0 (5)
```

## RAM NAM JAP

See `~/Projects/ram-nam-jap/docs/APP_STORE.md` — welcome screen, Help & privacy, v1.0.1+2.
