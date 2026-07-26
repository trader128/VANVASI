import Foundation

enum VANVASILegal {
    /// SavARun hub + per-app policy paths (add more apps under /apps/{id}/).
    static let publisherBase = "https://www.savarun.com"
    static let appPath = "/apps/vanvasi"
    static let siteBase = publisherBase + appPath

    static let privacyURL = URL(string: "\(siteBase)/privacy.html")!
    static let termsURL = URL(string: "\(siteBase)/terms.html")!
    static let supportURL = URL(string: "\(siteBase)/support.html")!
    static let appPageURL = URL(string: "\(siteBase)/")!

    static let developerName = "Lekhraj Dagur"
    static let supportEmail = "monudagur1@gmail.com"
    static let supportPhone = "+91 8401024176"
    static let supportPhoneTel = "+918401024176"

    static let copyrightLine = "2026 VANVASI App. All rights reserved."
    static let madeInIndiaLine = "Made in India with love."

    static let privacyPolicyText = """
    VANVASI Privacy Policy

    Last updated: July 2026
    Published by \(developerName) · \(supportEmail)

    VANVASI works on your iPhone only. No account. No cloud for core features.

    Data on your device
    • Free-app allowlist (Phone, Messages, VANVASI, etc.)
    • Monk mode on/off, unlock sessions, lock history
    • Merit points, focus habit score, streaks
    • Optional end-lock PIN (Keychain) or Face ID / device passcode
    • Optional payment records if paid unlocks are enabled (Apple processes payment)

    We do not sell your data. We do not use analytics or advertising SDKs. We do not read content inside other apps.

    Apple Screen Time
    VANVASI uses Apple's Family Controls / Screen Time APIs. Blocking data stays on your device per Apple's design.

    Notifications
    Local notifications may appear when you tap Unlock on a system shield so you can finish the flow in VANVASI.

    Children
    VANVASI is for users who choose to lock their own device. It is not parental monitoring software.

    Changes
    We may update this policy. The effective date on savarun.com will be updated.

    Contact
    \(developerName)
    Email: \(supportEmail)
    Phone: \(supportPhone)

    \(madeInIndiaLine)
    © \(copyrightLine)

    Full policy: \(siteBase)/privacy.html
    """
}
