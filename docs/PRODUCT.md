# VANVASI — Product & Market Research

## What VANVASI is

**Tagline:** Monk mode for your mind.

VANVASI is a self-imposed phone lock for adults who need hard focus:

- **Default locked:** Phone + Messages only
- **Everything else shielded** via Apple's Screen Time API
- **Unlock with intention:** breathing pause → confirm → timed access → auto re-lock
- **Private & fast:** all on-device, no server, no account required

This is the opposite of "soft nudges." VANVASI assumes you already decided you want protection — the app enforces that decision until you consciously override it.

---

## Competitor landscape (2025–2026)

### Opal — hard blocking + gamification

| Aspect | Detail |
|--------|--------|
| **Positioning** | "#1 Screen Time App" — focus on autopilot, focus score, sessions |
| **Tech** | Apple **Screen Time API / Family Controls** (same as VANVASI) |
| **UI** | Dark, premium, minimal; focus timers, soundscapes |
| **Differentiator** | Deep Focus (no bypass), Focus Score®, social sessions, Shortcuts sync |
| **Monetization** | Freemium + Opal Pro subscription |

**Takeaway for VANVASI:** Opal owns "scheduled focus sessions + analytics." VANVASI owns **default monk mode** — you're locked until you earn access back.

### One Sec — friction before open

| Aspect | Detail |
|--------|--------|
| **Positioning** | "Cut screen time in half" — pause before impulse |
| **Tech** | iOS **Shortcuts automations** (not Family Controls shields) |
| **UI** | Breathing overlay, calm dark screen, 7–10 sec pause |
| **Differentiator** | Breaks muscle memory; doesn't truly block |
| **Limitation** | User can disable Shortcuts; not a hard lock |

**Takeaway for VANVASI:** Borrow the **breathing pause UX** (UnlockConfirmView). VANVASI goes further with **system-level shields** that can't be dismissed with one tap.

### ScreenZen, Freedom, etc.

- **ScreenZen:** delay + intention prompts, lighter than Opal
- **Freedom:** cross-platform blocking, VPN/DNS on desktop
- **Apple Screen Time:** built-in but easy to ignore limits

---

## What makes this category feel "premium"

1. **Dark, calm visual system** — void backgrounds, soft gold/cream accents, serif headlines, glass cards
2. **Native Apple APIs** — Family Controls feels integrated, not hacky
3. **On-device privacy** — "your data never leaves your phone"
4. **Intentional friction** — breathing animation, haptics, no guilt copy
5. **Automatic re-lock** — user trusts the system to restore boundaries
6. **No clutter** — one primary action per screen
7. **Widget + shield polish** — brand consistency at every touchpoint

---

## VANVASI technology stack

| Layer | Technology | Why |
|-------|------------|-----|
| UI | **SwiftUI** | Native animations, dark mode, premium feel |
| App blocking | **FamilyControls + ManagedSettings** | System shields — strongest iOS lock |
| Shield UI | **ManagedSettingsUI** extensions | Custom block screen + actions |
| Re-lock timer | **DeviceActivity** extension | Auto restore lock after unlock window |
| Persistence | **SwiftData + App Groups** | Fast local storage, shared with extensions |
| Deep links | **vanasi://** URL scheme | Return from shield → unlock flow |
| Widget | **WidgetKit** | Lock status at a glance |

**Not using (v1):** StoreKit, backend server, Shortcuts, cloud sync — keeps the app fast and private.

---

## VANVASI positioning statement

> For people whose income or grades depend on focus, VANVASI is the iPhone lock that defaults to monk mode — calls and texts only — and makes every other unlock a conscious choice.

**Primary users:** traders, medical residents, law students, anyone who needs "phone becomes dumb phone until I decide otherwise."

**Not for:** parental monitoring (v1), Android, soft habit nudges.

---

## App Store description (draft)

**Subtitle:** Monk mode for your mind

**Description:**

Lock your iPhone to what matters. When VANVASI Lock is on, only Phone and Messages stay open. Everything else waits.

Before you unlock, take a breath. VANVASI pauses you — then grants timed access if you still need it. When the timer ends, monk mode returns automatically.

Built on Apple's Screen Time API. Your data stays on your device. No account. No cloud.

**Keywords:** screen time, focus, digital wellbeing, app blocker, monk mode, distraction blocker

---

## Roadmap ideas (post v1)

- Focus score / streak stats (Opal-inspired)
- Scheduled lock windows (sleep, market hours)
- Optional PIN to disable lock
- StoreKit for paid unlock tiers (removed from v1, can return later)
