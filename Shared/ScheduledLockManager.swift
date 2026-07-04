import Foundation

enum ScheduledLockManager {
    static var isEnabled: Bool {
        get { SharedStore.scheduledLockEnabled }
        set { SharedStore.scheduledLockEnabled = newValue }
    }

    static var startMinutes: Int {
        get {
            let v = SharedStore.store.integer(forKey: SharedKeys.scheduledLockStartMinutes)
            return v > 0 ? v : 9 * 60
        }
        set { SharedStore.store.set(newValue, forKey: SharedKeys.scheduledLockStartMinutes) }
    }

    static var endMinutes: Int {
        get {
            let v = SharedStore.store.integer(forKey: SharedKeys.scheduledLockEndMinutes)
            return v > 0 ? v : 17 * 60
        }
        set { SharedStore.store.set(newValue, forKey: SharedKeys.scheduledLockEndMinutes) }
    }

    static func applySchedule() {
        guard isEnabled else {
            DeviceActivityScheduler.stopScheduleMonitoring()
            return
        }
        DeviceActivityScheduler.scheduleDailyLock(startMinutes: startMinutes, endMinutes: endMinutes)
    }

    static func formattedWindow() -> String {
        "\(format(minutes: startMinutes)) – \(format(minutes: endMinutes))"
    }

    private static func format(minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        let period = h >= 12 ? "PM" : "AM"
        let hour12 = h % 12 == 0 ? 12 : h % 12
        return m == 0 ? "\(hour12) \(period)" : String(format: "%d:%02d %@", hour12, m, period)
    }
}
