import Foundation
import FamilyControls
import ManagedSettings

/// Shared shield logic for main app and DeviceActivity monitor extension.
enum ShieldPolicy {
    /// Block all apps except those in `selection` (+ optional temporary extras).
    /// Uses category policy only — `shield.applications` is a Set for explicit shields, not `.all(except:)`.
    static func applyFullLock(
        to store: ManagedSettingsStore,
        selection: FamilyActivitySelection,
        extraAllowedApps: Set<ApplicationToken> = []
    ) {
        let allowed = Set(selection.applicationTokens).union(extraAllowedApps)
        guard !allowed.isEmpty else { return }

        store.shield.applicationCategories = .all(except: allowed)
        store.shield.applications = nil
        store.shield.webDomainCategories = .all()
        store.shield.webDomains = nil
    }

    static func loadPersistedSelection() -> FamilyActivitySelection? {
        guard let data = SharedStore.store.data(forKey: SharedKeys.allowedSelectionData) else {
            return nil
        }
        return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    }
}
