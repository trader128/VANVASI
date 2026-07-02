# VANVASI

**Monk mode for your mind.** Lock your iPhone to calls and messages. Unlock with intention — not impulse.

## Start here

- **[SETUP.md](SETUP.md)** — open in Xcode, run on iPhone
- **[PLAN.md](PLAN.md)** — product plan
- **[docs/PRODUCT.md](docs/PRODUCT.md)** — positioning, competitors, tech stack

## Quick commands

```bash
cd ~/Projects/VANVASI
./scripts/generate-xcodeproj.sh
open VANVASI.xcodeproj
```

## How it works

1. **Lock ON** — Phone + Messages stay open; everything else is shielded
2. **Tap a blocked app** — breathing pause → confirm unlock (15–30 min)
3. **Timer ends** — lock returns automatically

No payments in v1. All data stays on your device via Apple's Screen Time API.

## Config

Edit unlock durations in `Shared/VANVASIConfig.swift`.
