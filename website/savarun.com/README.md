# Deploy to www.savarun.com

Nothing is uploaded automatically. Copy this folder to your **savarun.com** host.

## URL structure (one app page + three policy links per app)

| Purpose | URL |
|--------|-----|
| SavARun home (all apps) | https://www.savarun.com/ |
| **VANVASI app page** | https://www.savarun.com/apps/vanvasi/ |
| Privacy (VANVASI only) | https://www.savarun.com/apps/vanvasi/privacy.html |
| Terms (VANVASI only) | https://www.savarun.com/apps/vanvasi/terms.html |
| Support (VANVASI only) | https://www.savarun.com/apps/vanvasi/support.html |

## App Store Connect (VANVASI)

- **Privacy Policy URL:** `https://www.savarun.com/apps/vanvasi/privacy.html`
- **Support URL:** `https://www.savarun.com/apps/vanvasi/support.html`
- **Marketing URL (optional):** `https://www.savarun.com/apps/vanvasi/`

## Adding another app later

Copy `apps/vanvasi/` to `apps/your-app-id/`, edit the three policy HTML files, and add a card on `index.html`.

## Note on savarun.in

The old `website/savarun.in/` layout was removed from this repo. If you uploaded those files to **savarun.in**, delete them from that host or redirect to savarun.com — we did not change any live server from here.
