import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

class VANVASIDeviceActivityMonitor: DeviceActivityMonitor {
    private let store = ManagedSettingsStore(named: .init("vanasi-lock"))

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        SharedStore.store.removeObject(forKey: "tempUnlockUntil")
        SharedStore.store.removeObject(forKey: "tempUnlockAllUntil")
        SharedStore.store.removeObject(forKey: "pendingRelockScope")
        SharedStore.store.removeObject(forKey: "pendingRelockAt")

        guard SharedStore.monkLockEnabled else {
            store.clearAllSettings()
            return
        }

        if let selection = ShieldPolicy.loadPersistedSelection() {
            ShieldPolicy.applyFullLock(to: store, selection: selection)
        }
    }
}
