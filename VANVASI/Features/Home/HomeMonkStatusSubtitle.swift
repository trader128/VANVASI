import SwiftUI

/// Countdown subtitle isolated so the lock ring is not redrawn every second.
struct HomeMonkStatusSubtitle: View {
    let isLocked: Bool

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(Self.subtitle(isLocked: isLocked, at: context.date))
                .font(.subheadline.weight(.light))
                .foregroundStyle(VANASITheme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(minHeight: 40)
        }
    }

    static func subtitle(isLocked: Bool, at date: Date) -> String {
        let now = date.timeIntervalSince1970
        let breakUntil = max(
            SharedStore.store.double(forKey: SharedKeys.tempUnlockAllUntil),
            SharedStore.store.double(forKey: SharedKeys.tempUnlockUntil)
        )
        if breakUntil > now {
            let s = max(0, Int(breakUntil - now))
            let m = s / 60
            let sec = s % 60
            let tail = m > 0 ? "\(m)m \(sec)s" : "\(sec)s"
            return "Break ends in \(tail)"
        }
        if isLocked, let remaining = MonkSessionUntilManager.formattedSessionRemaining(now: date) {
            return "Session · \(remaining)"
        }
        return isLocked ? "Calls & messages only" : "Tap the ring to enable"
    }
}
