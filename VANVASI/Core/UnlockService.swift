import Foundation
import SwiftData

@MainActor
final class UnlockService {
    private let lockManager: MonkLockManager
    private let context: ModelContext

    init(lockManager: MonkLockManager, context: ModelContext) {
        self.lockManager = lockManager
        self.context = context
    }

    func grantUnlock(request: UnlockRequest) -> UnlockSession {
        let pricing = request.pricing
        let expires = Date().addingTimeInterval(TimeInterval(pricing.minutes * 60))

        let label: String
        let scope: UnlockScope

        switch request {
        case .singleApp(let appLabel):
            label = appLabel
            scope = .singleApp
            lockManager.temporarilyUnlockAll(until: expires)
        case .unlockAll:
            label = "Everything"
            scope = .unlockAll
            lockManager.temporarilyUnlockAll(until: expires)
        }

        DeviceActivityScheduler.scheduleRelock(at: expires, scope: scope)

        let session = UnlockSession(
            expiresAt: expires,
            scope: scope.rawValue,
            coinCost: 0,
            label: label
        )
        context.insert(session)
        try? context.save()
        return session
    }
}
