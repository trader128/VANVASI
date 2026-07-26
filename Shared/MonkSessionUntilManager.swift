import Foundation

/// Monk session length from lock-on (separate from 15/30 min unlock breaks).
enum MonkSessionUntilManager {
    static let durationOptions: [Int] = [15, 30, 60, 120]
    static let defaultDurationMinutes = 30

    static var preferenceDurationMinutes: Int {
        get {
            let v = SharedStore.store.integer(forKey: SharedKeys.monkSessionUntilPreferenceMinutes)
            if durationOptions.contains(v) { return v }
            if v == 0 || v > 180 { return defaultDurationMinutes }
            return defaultDurationMinutes
        }
        set {
            let clamped = durationOptions.contains(newValue) ? newValue : defaultDurationMinutes
            SharedStore.store.set(clamped, forKey: SharedKeys.monkSessionUntilPreferenceMinutes)
            SharedStore.store.set(true, forKey: SharedKeys.monkSessionUntilPreferenceEnabled)
        }
    }

    static var preferenceEnabled: Bool { true }

    static var activeUntil: Date? {
        guard SharedStore.store.bool(forKey: SharedKeys.monkSessionUntilActive) else { return nil }
        let ts = SharedStore.store.double(forKey: SharedKeys.monkSessionUntilTimestamp)
        guard ts > Date().timeIntervalSince1970 else { return nil }
        return Date(timeIntervalSince1970: ts)
    }

    static func activateForCurrentSession() {
        let duration = preferenceDurationMinutes
        let end = Date().addingTimeInterval(TimeInterval(duration * 60))
        SharedStore.store.set(true, forKey: SharedKeys.monkSessionUntilActive)
        SharedStore.store.set(end.timeIntervalSince1970, forKey: SharedKeys.monkSessionUntilTimestamp)
        DeviceActivityScheduler.scheduleMonkSessionEnd(at: end)
    }

    static func shouldEndSessionNow() -> Bool {
        guard SharedStore.store.bool(forKey: SharedKeys.monkSessionUntilActive) else { return false }
        let ts = SharedStore.store.double(forKey: SharedKeys.monkSessionUntilTimestamp)
        return ts > 0 && Date().timeIntervalSince1970 >= ts
    }

    static func clearActiveSession() {
        SharedStore.store.set(false, forKey: SharedKeys.monkSessionUntilActive)
        SharedStore.store.removeObject(forKey: SharedKeys.monkSessionUntilTimestamp)
        DeviceActivityScheduler.stopMonkSessionUntilMonitoring()
    }

    static func label(for minutes: Int) -> String {
        switch minutes {
        case 15: return "15m"
        case 30: return "30m"
        case 60: return "1h"
        case 120: return "2h"
        default: return "\(minutes)m"
        }
    }

    static func formattedSessionRemaining(now: Date = .now) -> String? {
        guard let until = activeUntil else { return nil }
        let s = max(0, Int(until.timeIntervalSince(now)))
        if s >= 3600 {
            return "\(s / 3600)h \((s % 3600) / 60)m left"
        }
        if s >= 60 {
            return "\(s / 60)m left"
        }
        return "\(s)s left"
    }
}
