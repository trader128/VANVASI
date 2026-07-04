import DeviceActivity
import Foundation

enum DeviceActivityScheduler {
    static let center = DeviceActivityCenter()
    static let unlockActivity = DeviceActivityName("com.vanasi.unlock")
    static let scheduleActivity = DeviceActivityName("com.vanasi.schedule")

    static func scheduleRelock(at end: Date, scope: UnlockScope) {
        let calendar = Calendar.current
        let start = Date()
        guard end > start else { return }

        let schedule = DeviceActivitySchedule(
            intervalStart: calendar.dateComponents([.hour, .minute, .second], from: start),
            intervalEnd: calendar.dateComponents([.hour, .minute, .second], from: end),
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

    /// Daily recurring window — monitor enables lock at start, optional disable at end.
    static func scheduleDailyLock(startMinutes: Int, endMinutes: Int) {
        stopScheduleMonitoring()

        let startH = startMinutes / 60
        let startM = startMinutes % 60
        let endH = endMinutes / 60
        let endM = endMinutes % 60

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startH, minute: startM),
            intervalEnd: DateComponents(hour: endH, minute: endM),
            repeats: true
        )

        do {
            try center.startMonitoring(scheduleActivity, during: schedule)
        } catch {
            // Simulator fallback — user can toggle manually.
        }
    }

    static func stopScheduleMonitoring() {
        center.stopMonitoring([scheduleActivity])
    }

    static func stopMonitoring() {
        center.stopMonitoring([unlockActivity, scheduleActivity])
    }
}
