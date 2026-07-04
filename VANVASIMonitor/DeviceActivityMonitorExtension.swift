import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

class VANVASIDeviceActivityMonitor: DeviceActivityMonitor {
    private let store = ManagedSettingsStore(named: .init("vanasi-lock"))

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard activity == DeviceActivityScheduler.scheduleActivity else { return }
        guard ScheduledLockManager.isEnabled else { return }

        SharedStore.monkLockEnabled = true
        if let selection = ShieldPolicy.loadPersistedSelection() {
            ShieldPolicy.applyFullLock(to: store, selection: selection)
        }
        SharedStore.store.set(Date().timeIntervalSince1970, forKey: SharedKeys.lockSessionStartedAt)
        WidgetReloader.reloadLockWidget()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        if activity == DeviceActivityScheduler.scheduleActivity {
            // End of scheduled window — keep lock if user manually enabled outside schedule
            return
        }

        SharedStore.clearTempUnlockKeys()
        SharedStore.store.removeObject(forKey: "pendingRelockScope")
        SharedStore.store.removeObject(forKey: "pendingRelockAt")

        guard SharedStore.monkLockEnabled else {
            store.clearAllSettings()
            WidgetReloader.reloadLockWidget()
            return
        }

        if let selection = ShieldPolicy.loadPersistedSelection() {
            ShieldPolicy.applyFullLock(to: store, selection: selection)
        }
        WidgetReloader.reloadLockWidget()
    }
}
