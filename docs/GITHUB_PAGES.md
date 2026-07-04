# GitHub Pages — VANVASI legal & support site

Static pages for **App Store Connect** (privacy URL, support URL, marketing URL).

## Pages

| Page | File | App Store use |
|------|------|----------------|
| Home | `index.html` | Marketing URL (optional) |
| Privacy | `privacy.html` | **Privacy Policy URL** (required) |
| Support | `support.html` | **Support URL** (required) |
| Terms | `terms.html` | Optional / good practice |

## Enable GitHub Pages (one time)

1. Push this repo to GitHub (e.g. `github.com/YOUR_USERNAME/VANVASI`)
2. Repo **Settings → Pages**
3. **Build and deployment → Source:** Deploy from a branch
4. **Branch:** `main` (or `master`) → folder **`/docs`**
5. Save — site live in ~1–2 minutes

## Your URLs (replace YOUR_USERNAME)

If the repo is named **VANVASI**:

| Purpose | URL |
|---------|-----|
| Marketing | `https://YOUR_USERNAME.github.io/VANVASI/` |
| Privacy Policy | `https://YOUR_USERNAME.github.io/VANVASI/privacy.html` |
| Support | `https://YOUR_USERNAME.github.io/VANVASI/support.html` |
| Terms | `https://YOUR_USERNAME.github.io/VANVASI/terms.html` |

Paste **Privacy** and **Support** URLs into App Store Connect → App Information.

## Push to GitHub

```bash
cd ~/Projects/VANVASI
git init   # if not already a repo
git add .
git commit -m "Add app icon, GitHub Pages legal site"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/VANVASI.git
git push -u origin main
```

Then enable Pages as above.

## Local preview

```bash
cd docs && python3 -m http.server 8080
# Open http://localhost:8080
```

## Contact email

Pages reference `support@vanasi.app`. Update HTML files if you use a different address.
