import Foundation
import FamilyControls
import ManagedSettings

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
    func enableLock() -> Bool {
        lastError = nil

        #if targetEnvironment(simulator)
        persistSelection()
        isLockEnabled = true
        SharedStore.monkLockEnabled = true
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

        isLockEnabled = true
        SharedStore.monkLockEnabled = true
        return true
        #endif
    }

    func disableLock() {
        #if !targetEnvironment(simulator)
        DeviceActivityScheduler.stopMonitoring()
        store.clearAllSettings()
        #endif
        isLockEnabled = false
        SharedStore.monkLockEnabled = false
        lastError = nil
    }

    func applyShieldPolicy(extraAllowed: Set<ApplicationToken> = []) {
        guard allowedSelection.isValidAllowlist else { return }
        ShieldPolicy.applyFullLock(to: store, selection: allowedSelection, extraAllowedApps: extraAllowed)
    }

    func temporarilyAllow(app token: ApplicationToken, until: Date) {
        ShieldPolicy.applyFullLock(to: store, selection: allowedSelection, extraAllowedApps: Set([token]))
        SharedStore.store.set(until.timeIntervalSince1970, forKey: "tempUnlockUntil")
    }

    func temporarilyUnlockAll(until: Date) {
        store.clearAllSettings()
        SharedStore.store.set(until.timeIntervalSince1970, forKey: "tempUnlockAllUntil")
    }

    func restoreLockIfNeeded() {
        guard isLockEnabled else { return }

        let now = Date().timeIntervalSince1970
        if SharedStore.store.double(forKey: "tempUnlockAllUntil") > now { return }
        if SharedStore.store.double(forKey: "tempUnlockUntil") > now { return }

        applyShieldPolicy()
    }

    func persistSelection() {
        if let data = try? JSONEncoder().encode(allowedSelection) {
            SharedStore.store.set(data, forKey: SharedKeys.allowedSelectionData)
        }
    }

    private func loadSelection() {
        guard let data = SharedStore.store.data(forKey: SharedKeys.allowedSelectionData),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return }
        allowedSelection = selection
    }
}
