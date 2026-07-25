import Foundation

/// Merit writes from app extensions (shield) — main app shows toast via `FocusPointsService`.
enum MeritAwardBridge {
    static func recordStayFocusedFromShield() {
        let amount = VANVASIConfig.pointsStayFocused
        guard amount > 0 else { return }
        let total = SharedStore.store.integer(forKey: SharedKeys.focusPointsTotal) + amount
        SharedStore.store.set(total, forKey: SharedKeys.focusPointsTotal)
        SharedStore.store.set(amount, forKey: SharedKeys.pendingMeritGainAmount)
        SharedStore.store.set("Stayed focused", forKey: SharedKeys.pendingMeritGainReason)
        WidgetReloader.reloadLockWidget()
    }

    static func consumePendingGain() -> (amount: Int, reason: String)? {
        let amount = SharedStore.store.integer(forKey: SharedKeys.pendingMeritGainAmount)
        guard amount > 0,
              let reason = SharedStore.store.string(forKey: SharedKeys.pendingMeritGainReason) else {
            return nil
        }
        SharedStore.store.removeObject(forKey: SharedKeys.pendingMeritGainAmount)
        SharedStore.store.removeObject(forKey: SharedKeys.pendingMeritGainReason)
        return (amount, reason)
    }
}
