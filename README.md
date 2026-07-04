# VANVASI

**Monk mode for your mind.** Lock your iPhone to calls and messages. Unlock with intention — not impulse.

## Start here

- **[GitHub repo](https://github.com/trader128/VANVASI)** — source code
- **[Privacy](https://trader128.github.io/VANVASI/privacy.html)** · **[Support](https://trader128.github.io/VANVASI/support.html)** — App Store URLs
- **[docs/SUBMISSION.md](docs/SUBMISSION.md)** — App Store Connect submission guide
- **[STATUS.md](STATUS.md)** — what's done across all 5 phases
- **[SETUP.md](SETUP.md)** — Xcode, signing, device testing
- **[PLAN.md](PLAN.md)** — product plan
- **[docs/PRODUCT.md](docs/PRODUCT.md)** — positioning & competitors
- **[docs/APP_STORE.md](docs/APP_STORE.md)** — App Store listing draft
- **[docs/TESTFLIGHT.md](docs/TESTFLIGHT.md)** — beta checklist

## Quick commands

```bash
cd ~/Projects/VANVASI
bash ./scripts/generate-xcodeproj.sh
open VANVASI.xcodeproj
bash ./scripts/device-test-checklist.sh   # on-device QA steps
```

## Features

- **Monk mode lock** — Phone + Messages only (system shields)
- **Intentional unlock** — breathing pause before access
- **Focus score & streak** — home screen stats
- **Session history** — unlocks and lock events
- **Scheduled lock** — auto-enable daily window
- **PIN protection** — gate disable/end lock
- **Shortcuts** — Siri & automations
- **Widget** — lock status
- **Optional payments** — StoreKit pay-to-unlock (Settings, off by default)

All core data stays on your device.

## Config

`Shared/VANVASIConfig.swift` — unlock durations, product IDs
