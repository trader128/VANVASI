import Foundation
import SwiftData

enum FocusStatsCalculator {
    static func compute(sessions: [UnlockSession], events: [LockEvent]) -> FocusStats {
        let calendar = Calendar.current
        let unlockCount = sessions.count

        let streak = computeStreak(events: events, calendar: calendar)
        let protectedMinutes = computeProtectedMinutes(events: events)
        let focusScore = min(100, (streak * 8) + max(0, 40 - unlockCount * 2) + min(30, protectedMinutes / 60))

        return FocusStats(
            unlockCount: unlockCount,
            streakDays: streak,
            protectedMinutes: protectedMinutes,
            focusScore: focusScore
        )
    }

    private static func computeStreak(events: [LockEvent], calendar: Calendar) -> Int {
        let lockDays = Set(
            events
                .filter { $0.action == LockEventAction.enabled || $0.action == LockEventAction.scheduledEnable }
                .map { calendar.startOfDay(for: $0.date) }
        )
        guard !lockDays.isEmpty else { return 0 }

        var streak = 0
        var day = calendar.startOfDay(for: .now)
        while lockDays.contains(day) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    private static func computeProtectedMinutes(events: [LockEvent]) -> Int {
        let sorted = events.sorted { $0.date < $1.date }
        var total = 0
        var lockStart: Date?

        for event in sorted {
            switch event.action {
            case LockEventAction.enabled, LockEventAction.scheduledEnable, LockEventAction.focusSyncEnable:
                lockStart = event.date
            case LockEventAction.disabled, LockEventAction.emergencyExit, LockEventAction.scheduledDisable:
                if let start = lockStart {
                    total += Int(event.date.timeIntervalSince(start) / 60)
                }
                lockStart = nil
            default:
                break
            }
        }

        if let start = lockStart {
            total += Int(Date().timeIntervalSince(start) / 60)
        } else if SharedStore.monkLockEnabled,
                  let ts = SharedStore.store.object(forKey: SharedKeys.lockSessionStartedAt) as? Double {
            total += Int(Date().timeIntervalSince1970 - ts) / 60
        }

        return max(0, total)
    }
}
