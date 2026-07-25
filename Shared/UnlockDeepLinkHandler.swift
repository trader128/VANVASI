import Foundation

enum UnlockDeepLinkHandler {
    static func request(from url: URL) -> UnlockRequest? {
        guard url.scheme == VANVASIConfig.urlScheme else { return nil }
        let host = url.host ?? "unlock"
        guard host == "unlock" || host == "paywall" else { return nil }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let scope = items.first(where: { $0.name == "scope" })?.value ?? UnlockScope.unlockAll.rawValue
        let label = items.first(where: { $0.name == "label" })?.value ?? "This app"
        switch scope {
        case UnlockScope.singleApp.rawValue: return .singleApp(label: label)
        default: return .unlockAll
        }
    }
}
