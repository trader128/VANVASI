import Foundation
import FamilyControls
import ManagedSettings
import SwiftData

@MainActor
final class MonkLockManager: ObservableObject {
    static let shared = MonkLockManager()

    private let store = ManagedSettingsStore(named: .init("vanasi-lock"))

    @Published private(set) var isLockEnabled = false
    @Published var allowedSelection = FamilyActivitySelection()
    @Published var lastError: String?

    private init() {
        isLockEnabled = SharedStore.monkLockEnabled
        loadSelection()
    }

    @discardableResult
    func enableLock(logEvent: Bool = true) -> Bool {
        lastError = nil

        #if targetEnvironment(simulator)
        persistSelection()
        applyEnabledState(logEvent: logEvent)
        return true
        #else

        guard AuthorizationCenter.shared.authorizationStatus == .approved else {
            lastError = LockManagerError.authorizationDenied.localizedDescription
            return false
        }

        guard allowedSelection.isValidAllowlist else {
            lastError = LockManagerError.noAppsSelected.localizedDescription
            return false
        }

        persistSelection()
        ShieldPolicy.applyFullLock(to: store, selection: allowedSelection)
        applyEnabledState(logEvent: logEvent)
        return true
        #endif
    }

    func disableLock(requirePIN: Bool = true, pin: String? = nil, context: ModelContext? = nil) -> Bool {
        if requirePIN && SharedStore.pinEnabled {
            guard let pin, PINProtection.verify(pin: pin) else {
                lastError = "Incorrect PIN."
                return false
            }
        }

        #if !targetEnvironment(simulator)
        DeviceActivityScheduler.stopMonitoring()
        store.clearAllSettings()
        #endif

        isLockEnabled = false
        SharedStore.monkLockEnabled = false
        SharedStore.store.removeObject(forKey: SharedKeys.lockSessionStartedAt)
        SharedStore.clearTempUnlockKeys()
        lastError = nil
        WidgetReloader.reloadLockWidget()

        if let context {
            context.insert(LockEvent(action: LockEventAction.disabled))
            try? context.save()
        }
        return true
    }

    func applyShieldPolicy(extraAllowed: Set<ApplicationToken> = []) {
        guard allowedSelection.isValidAllowlist else { return }
        ShieldPolicy.applyFullLock(to: store, selection: allowedSelection, extraAllowedApps: extraAllowed)
    }

    func temporarilyAllow(app token: ApplicationToken, until: Date) {
        ShieldPolicy.applyFullLock(to: store, selection: allowedSelection, extraAllowedApps: [token])
        SharedStore.store.set(until.timeIntervalSince1970, forKey: SharedKeys.tempUnlockUntil)
        SharedStore.store.removeObject(forKey: SharedKeys.tempUnlockAllUntil)
    }

    func temporarilyUnlockAll(until: Date) {
        store.clearAllSettings()
        SharedStore.store.set(until.timeIntervalSince1970, forKey: SharedKeys.tempUnlockAllUntil)
        SharedStore.store.removeObject(forKey: SharedKeys.tempUnlockUntil)
        SharedStore.store.removeObject(forKey: SharedKeys.pendingUnlockAppToken)
    }

    func restoreLockIfNeeded() {
        guard isLockEnabled else { return }

        let now = Date().timeIntervalSince1970
        if SharedStore.store.double(forKey: SharedKeys.tempUnlockAllUntil) > now { return }
        if SharedStore.store.double(forKey: SharedKeys.tempUnlockUntil) > now { return }

        applyShieldPolicy()
    }

    func persistSelection() {
        if let data = try? JSONEncoder().encode(allowedSelection) {
            SharedStore.store.set(data, forKey: SharedKeys.allowedSelectionData)
        }
    }

    func pendingUnlockAppToken() -> ApplicationToken? {
        guard let data = SharedStore.store.data(forKey: SharedKeys.pendingUnlockAppToken),
              let token = try? JSONDecoder().decode(ApplicationToken.self, from: data) else {
            return nil
        }
        return token
    }

    func clearPendingUnlockAppToken() {
        SharedStore.store.removeObject(forKey: SharedKeys.pendingUnlockAppToken)
    }

    private func applyEnabledState(logEvent: Bool) {
        isLockEnabled = true
        SharedStore.monkLockEnabled = true
        SharedStore.store.set(Date().timeIntervalSince1970, forKey: SharedKeys.lockSessionStartedAt)
        WidgetReloader.reloadLockWidget()
        if logEvent {
            // LockEvent inserted by caller when ModelContext available
        }
    }

    private func loadSelection() {
        guard let data = SharedStore.store.data(forKey: SharedKeys.allowedSelectionData),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return }
        allowedSelection = selection
    }
}
