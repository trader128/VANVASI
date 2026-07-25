import Foundation
import ActivityKit

struct MonkModeActivityAttributes: ActivityAttributes {
    enum Mode: String, Codable, Hashable {
        case monkModeActive
        case unlockWindow
    }

    struct ContentState: Codable, Hashable {
        var mode: Mode
        var relockAt: Date?
        var meritPoints: Int
        var unlockLabel: String?
    }

    var appName: String
}
