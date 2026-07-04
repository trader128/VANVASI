import Foundation

enum VANVASIConfig {
    static let singleAppMinutes = 15
    static let unlockAllMinutes = 30
    static let urlScheme = "vanasi"

    // StoreKit product IDs (Phase 5 — enable in Settings)
    static let productIDSingleApp = "com.vanasi.unlock.app"
    static let productIDUnlockAll = "com.vanasi.unlock.all"
    static let singleAppPriceLabel = "$0.99"
    static let unlockAllPriceLabel = "$2.99"

    static func unlockURL(scope: UnlockScope, label: String = "App") -> URL {
        var c = URLComponents()
        c.scheme = urlScheme
        c.host = "unlock"
        c.queryItems = [
            URLQueryItem(name: "scope", value: scope.rawValue),
            URLQueryItem(name: "label", value: label)
        ]
        return c.url ?? URL(string: "\(urlScheme)://unlock")!
    }
}

enum UnlockScope: String {
    case singleApp = "app"
    case unlockAll = "all"
}

enum LockEventAction {
    static let enabled = "lock_enabled"
    static let disabled = "lock_disabled"
    static let emergencyExit = "emergency_exit"
    static let scheduledEnable = "scheduled_enable"
    static let scheduledDisable = "scheduled_disable"
    static let focusSyncEnable = "focus_sync_enable"
}
