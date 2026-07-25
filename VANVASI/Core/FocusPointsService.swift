import Foundation
import Combine

/// On-device merit points — small wins for monk mode, streaks, and resisting unlock.
@MainActor
final class FocusPointsService: ObservableObject {
    static let shared = FocusPointsService()

    struct PointGain: Identifiable, Equatable {
        let id = UUID()
        let amount: Int
        let reason: String
    }

    @Published private(set) var total: Int = 0
    @Published var recentGain: PointGain?

    private init() {
        total = SharedStore.store.integer(forKey: SharedKeys.focusPointsTotal)
    }

    var level: Int {
        max(1, total / VANVASIConfig.pointsPerLevel + 1)
    }

    var progressInLevel: Double {
        Double(total % VANVASIConfig.pointsPerLevel) / Double(VANVASIConfig.pointsPerLevel)
    }

    var levelTitle: String {
        switch level {
        case 1: return "Novice"
        case 2: return "Seeker"
        case 3: return "Monk"
        case 4: return "Anchor"
        default: return "Master"
        }
    }

    func recordLockEngaged() {
        award(VANVASIConfig.pointsLockEngaged, reason: "Monk mode on")
    }

    func recordStayFocused() {
        award(VANVASIConfig.pointsStayFocused, reason: "Stayed focused")
    }

    func syncLockedTimeRewards() {
        guard SharedStore.monkLockEnabled else { return }
        let startTs = SharedStore.store.double(forKey: SharedKeys.lockSessionStartedAt)
        guard startTs > 0 else { return }

        let minutesLocked = Int(Date().timeIntervalSince1970 - startTs) / 60
        let buckets = minutesLocked / 5
        let lastBuckets = SharedStore.store.integer(forKey: SharedKeys.focusPointsFiveMinuteBuckets)
        guard buckets > lastBuckets else { return }

        let gained = (buckets - lastBuckets) * VANVASIConfig.pointsPerFiveMinutesLocked
        SharedStore.store.set(buckets, forKey: SharedKeys.focusPointsFiveMinuteBuckets)
        award(gained, reason: "Protected focus")
    }

    func syncStreakBonus(streakDays: Int) {
        guard streakDays > 0 else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now).timeIntervalSince1970
        let last = SharedStore.store.double(forKey: SharedKeys.focusPointsLastStreakBonusDay)
        guard today > last else { return }

        SharedStore.store.set(today, forKey: SharedKeys.focusPointsLastStreakBonusDay)
        let bonus = VANVASIConfig.pointsStreakDayBonus + (streakDays - 1) * 5
        award(bonus, reason: "\(streakDays)-day streak")
    }

    func resetSessionBucketsIfNeeded(wasLocked: Bool, isLocked: Bool) {
        if !isLocked {
            SharedStore.store.set(0, forKey: SharedKeys.focusPointsFiveMinuteBuckets)
        } else if !wasLocked && isLocked {
            SharedStore.store.set(0, forKey: SharedKeys.focusPointsFiveMinuteBuckets)
        }
    }

    private func award(_ amount: Int, reason: String) {
        guard amount > 0 else { return }
        total += amount
        SharedStore.store.set(total, forKey: SharedKeys.focusPointsTotal)
        recentGain = PointGain(amount: amount, reason: reason)
    }

    func clearRecentGain() {
        recentGain = nil
    }
}
