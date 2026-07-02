import Foundation

enum VANVASIConfig {
    static let singleAppMinutes = 15
    static let unlockAllMinutes = 30
    static let urlScheme = "vanasi"

    static func unlockURL(scope: UnlockScope, label: String = "App") -> URL {
        var c = URLComponents()
        c.scheme = urlScheme
        c.host = "unlock"
        c.queryItems = [
            URLQueryItem(name: "scope", value: scope.rawValue),
            URLQueryItem(name: "label", value: label)
        ]
        return c.url ?? URL(string: "\(urlScheme)://unlock")!
    }
}

enum UnlockScope: String {
    case singleApp = "app"
    case unlockAll = "all"
}
