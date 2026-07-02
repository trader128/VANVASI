import Foundation

enum UnlockPricing: CaseIterable {
    case singleApp
    case unlockAll

    var minutes: Int {
        switch self {
        case .singleApp: return VANVASIConfig.singleAppMinutes
        case .unlockAll: return VANVASIConfig.unlockAllMinutes
        }
    }

    var scope: UnlockScope {
        switch self {
        case .singleApp: return .singleApp
        case .unlockAll: return .unlockAll
        }
    }

    var title: String {
        switch self {
        case .singleApp: return "Open this app"
        case .unlockAll: return "Full access"
        }
    }

    var subtitle: String {
        "\(minutes) minutes, then lock returns."
    }

    var unlockRequest: UnlockRequest {
        switch self {
        case .singleApp: return .singleApp(label: "App")
        case .unlockAll: return .unlockAll
        }
    }
}

enum UnlockRequest: Equatable {
    case singleApp(label: String)
    case unlockAll
}

extension UnlockRequest {
    var pricing: UnlockPricing {
        switch self {
        case .singleApp: return .singleApp
        case .unlockAll: return .unlockAll
        }
    }
}
