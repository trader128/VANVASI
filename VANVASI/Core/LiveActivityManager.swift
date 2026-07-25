import Foundation
import ActivityKit

@MainActor
enum LiveActivityManager {
    static var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    static func syncMonkModeLocked(meritPoints: Int) {
        guard SharedStore.monkLockEnabled else {
            endAll()
            return
        }

        if let end = unlockEndDate() {
            startOrUpdateUnlock(until: end, meritPoints: meritPoints, label: nil)
        } else {
            startOrUpdateLocked(meritPoints: meritPoints)
        }
    }

    static func showUnlockWindow(until: Date, meritPoints: Int, label: String?) {
        startOrUpdateUnlock(until: until, meritPoints: meritPoints, label: label)
    }

    static func endAll() {
        let activities = Activity<MonkModeActivityAttributes>.activities
        guard !activities.isEmpty else { return }
        Task {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    private static func startOrUpdateLocked(meritPoints: Int) {
        let state = MonkModeActivityAttributes.ContentState(
            mode: .monkModeActive,
            relockAt: nil,
            meritPoints: meritPoints,
            unlockLabel: nil
        )
        startOrUpdate(state: state)
    }

    private static func startOrUpdateUnlock(until: Date, meritPoints: Int, label: String?) {
        let state = MonkModeActivityAttributes.ContentState(
            mode: .unlockWindow,
            relockAt: until,
            meritPoints: meritPoints,
            unlockLabel: label
        )
        startOrUpdate(state: state)
    }

    private static func startOrUpdate(state: MonkModeActivityAttributes.ContentState) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        if let existing = Activity<MonkModeActivityAttributes>.activities.first {
            Task {
                await existing.update(ActivityContent(state: state, staleDate: state.relockAt))
            }
            return
        }

        let attributes = MonkModeActivityAttributes(appName: "VANVASI")
        do {
            _ = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: state.relockAt),
                pushType: nil
            )
        } catch {
            // Live Activities disabled or unavailable
        }
    }

    private static func unlockEndDate() -> Date? {
        let ts = max(
            SharedStore.store.double(forKey: SharedKeys.tempUnlockAllUntil),
            SharedStore.store.double(forKey: SharedKeys.tempUnlockUntil)
        )
        guard ts > Date().timeIntervalSince1970 else { return nil }
        return Date(timeIntervalSince1970: ts)
    }
}
