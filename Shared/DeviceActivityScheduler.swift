import DeviceActivity
import Foundation

enum DeviceActivityScheduler {
    static let center = DeviceActivityCenter()
    static let unlockActivity = DeviceActivityName("com.vanasi.unlock")

    static func scheduleRelock(at end: Date, scope: UnlockScope) {
        let calendar = Calendar.current
        let start = Date()
        guard end > start else { return }

        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: start)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: end)

        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )

        SharedStore.store.set(scope.rawValue, forKey: "pendingRelockScope")
        SharedStore.store.set(end.timeIntervalSince1970, forKey: "pendingRelockAt")

        do {
            try center.startMonitoring(unlockActivity, during: schedule)
        } catch {
            // Monitor may fail in simulator; main app restoreLockIfNeeded is fallback.
        }
    }

    static func stopMonitoring() {
        center.stopMonitoring([unlockActivity])
    }
}
