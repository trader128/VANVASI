import Foundation

/// User-facing notes about Apple Screen Time / shield limits (not VANVASI-specific bugs).
enum VANVASIShieldCopy {
    static let iosMayStayAvailableTitle = "Some apps may never lock"

    static let iosMayStayAvailableBody = """
    Apple’s Screen Time API cannot shield every app. Watch, Files, and Safari (and a few other system apps) may stay available even in monk mode. VANVASI still blocks most apps — social, games, mail, and more.
    """

    static let iosMayStayAvailableShort =
        "Watch, Files, and Safari may stay open — an iOS limit, not your free-apps list."

    static let freeAppsReminder =
        "Only apps you pick below stay free on purpose (e.g. Phone, Messages, VANVASI)."
}
