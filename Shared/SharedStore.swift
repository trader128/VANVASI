import Foundation

enum AppGroup {
    static let identifier = "group.com.vanasi.shared"
    static let store = UserDefaults(suiteName: identifier)!
}

enum SharedKeys {
    static let monkLockEnabled = "monkLockEnabled"
    static let allowedSelectionData = "allowedSelectionData"
    static let pendingUnlockScope = "pendingUnlockScope"
    static let pendingUnlockURL = "pendingUnlockURL"
    static let pendingUnlockAppToken = "pendingUnlockAppToken"
    static let tempUnlockUntil = "tempUnlockUntil"
    static let tempUnlockAllUntil = "tempUnlockAllUntil"
    static let lockSessionStartedAt = "lockSessionStartedAt"
    static let pinEnabled = "pinEnabled"
    static let scheduledLockEnabled = "scheduledLockEnabled"
    static let scheduledLockStartMinutes = "scheduledLockStartMinutes"
    static let scheduledLockEndMinutes = "scheduledLockEndMinutes"
    static let focusModeSyncEnabled = "focusModeSyncEnabled"
    static let paymentsEnabled = "paymentsEnabled"
}

struct SharedStore {
    static var store: UserDefaults { AppGroup.store }

    static var monkLockEnabled: Bool {
        get { AppGroup.store.bool(forKey: SharedKeys.monkLockEnabled) }
        set { AppGroup.store.set(newValue, forKey: SharedKeys.monkLockEnabled) }
    }

    static var paymentsEnabled: Bool {
        get { AppGroup.store.bool(forKey: SharedKeys.paymentsEnabled) }
        set { AppGroup.store.set(newValue, forKey: SharedKeys.paymentsEnabled) }
    }

    static var pinEnabled: Bool {
        get { AppGroup.store.bool(forKey: SharedKeys.pinEnabled) }
        set { AppGroup.store.set(newValue, forKey: SharedKeys.pinEnabled) }
    }

    static var scheduledLockEnabled: Bool {
        get { AppGroup.store.bool(forKey: SharedKeys.scheduledLockEnabled) }
        set { AppGroup.store.set(newValue, forKey: SharedKeys.scheduledLockEnabled) }
    }

    static func clearTempUnlockKeys() {
        store.removeObject(forKey: SharedKeys.tempUnlockUntil)
        store.removeObject(forKey: SharedKeys.tempUnlockAllUntil)
        store.removeObject(forKey: SharedKeys.pendingUnlockAppToken)
    }
}

#if canImport(WidgetKit)
import WidgetKit

enum WidgetReloader {
    static func reloadLockWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "VANVASIWidget")
    }
}
#else
enum WidgetReloader {
    static func reloadLockWidget() {}
}
#endif
