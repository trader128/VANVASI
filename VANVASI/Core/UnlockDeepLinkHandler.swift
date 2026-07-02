import Foundation

enum UnlockDeepLinkHandler {
    static func request(from url: URL) -> UnlockRequest? {
        guard url.scheme == VANVASIConfig.urlScheme else { return nil }
        let host = url.host ?? "unlock"
        guard host == "unlock" || host == "paywall" else { return nil }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let scope = items.first(where: { $0.name == "scope" })?.value ?? UnlockScope.unlockAll.rawValue
        let label = items.first(where: { $0.name == "label" })?.value ?? "App"
        switch scope {
        case UnlockScope.singleApp.rawValue: return .singleApp(label: label)
        default: return .unlockAll
        }
    }

    static func pendingFromShield() -> UnlockRequest? {
        guard let scope = SharedStore.store.string(forKey: "pendingUnlockScope") else { return nil }
        SharedStore.store.removeObject(forKey: "pendingUnlockScope")
        switch scope {
        case UnlockScope.singleApp.rawValue: return .singleApp(label: "App")
        case UnlockScope.unlockAll.rawValue: return .unlockAll
        default: return nil
        }
    }
}
