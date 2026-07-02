import Foundation

enum AppGroup {
    static let identifier = "group.com.vanasi.shared"
    static let store = UserDefaults(suiteName: identifier)!
}

enum SharedKeys {
    static let monkLockEnabled = "monkLockEnabled"
    static let allowedSelectionData = "allowedSelectionData"
}

struct SharedStore {
    static var store: UserDefaults { AppGroup.store }

    static var monkLockEnabled: Bool {
        get { AppGroup.store.bool(forKey: SharedKeys.monkLockEnabled) }
        set { AppGroup.store.set(newValue, forKey: SharedKeys.monkLockEnabled) }
    }
}
