import Foundation

/// Single entry for shield, notifications, and deep links → unlock pause screen.
enum PendingUnlockRouter {
    static func consumePendingRequest() -> UnlockRequest? {
        if let urlString = SharedStore.store.string(forKey: SharedKeys.pendingUnlockURL),
           let url = URL(string: urlString),
           let request = UnlockDeepLinkHandler.request(from: url) {
            SharedStore.store.removeObject(forKey: SharedKeys.pendingUnlockURL)
            SharedStore.store.removeObject(forKey: SharedKeys.pendingUnlockScope)
            return request
        }

        if let scope = SharedStore.store.string(forKey: SharedKeys.pendingUnlockScope) {
            SharedStore.store.removeObject(forKey: SharedKeys.pendingUnlockScope)
            switch scope {
            case UnlockScope.singleApp.rawValue:
                return .singleApp(label: "This app")
            case UnlockScope.unlockAll.rawValue:
                return .unlockAll
            default:
                return nil
            }
        }

        return nil
    }

    static func signalPendingUnlockAvailable() {
        NotificationCenter.default.post(name: .vanasiOpenPendingUnlock, object: nil)
    }
}

extension Notification.Name {
    static let vanasiOpenPendingUnlock = Notification.Name("vanasiOpenPendingUnlock")
}
