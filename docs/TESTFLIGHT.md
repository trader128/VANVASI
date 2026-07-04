# TestFlight Checklist

## Before upload

- [ ] Family Controls entitlement approved by Apple
- [ ] All 5 targets signed with same Team ID
- [ ] Build on physical iPhone — shields work
- [ ] Onboarding completes with Phone + Messages + VANVASI selected
- [ ] Blocked app shows shield → unlock flow works
- [ ] Auto re-lock after 15/30 min
- [ ] Widget shows correct status
- [ ] PIN disable flow works
- [ ] Scheduled lock registers (check next day)
- [ ] Shortcuts: "Enable VANVASI Lock" runs
- [ ] Privacy manifest included (`PrivacyInfo.xcprivacy`)
- [ ] App Store Connect: create app record `com.vanasi.app`
- [ ] If payments enabled: create IAP products (see SETUP.md)

## Upload

```bash
# Archive in Xcode: Product → Archive → Distribute → App Store Connect
```

Or:

```bash
xcodebuild -project VANVASI.xcodeproj -scheme VANVASI -archivePath build/VANVASI.xcarchive archive
```

## Beta testers

1. App Store Connect → TestFlight → Internal Testing
2. Add testers by email
3. Share focus: traders, students, heavy phone users

## Feedback to collect

- Does shield appear reliably?
- Is breathing pause long enough?
- Any lock-out issues (forgot VANVASI in allowlist)?
- Focus score motivation?
