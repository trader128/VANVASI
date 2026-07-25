import Foundation

/// How the user must confirm turning off monk mode (home ring or End lock).
enum EndLockProtectionMode: String, CaseIterable, Identifiable {
    case none
    case fourDigitPIN
    case faceID
    case devicePasscode

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: return "Off"
        case .fourDigitPIN: return "4-digit PIN"
        case .faceID: return "Face ID"
        case .devicePasscode: return "iPhone passcode"
        }
    }

    var subtitle: String {
        switch self {
        case .none: return "Turn off monk mode without extra steps"
        case .fourDigitPIN: return "PIN you set in VANVASI"
        case .faceID: return "Face ID or Touch ID only"
        case .devicePasscode: return "Face ID, Touch ID, or device passcode"
        }
    }

    var requiresSystemAuth: Bool {
        self == .faceID || self == .devicePasscode
    }

    var requiresPINEntry: Bool {
        self == .fourDigitPIN
    }
}

enum EndLockProtectionStore {
    static var mode: EndLockProtectionMode {
        get {
            if let raw = SharedStore.store.string(forKey: SharedKeys.endLockProtectionMode),
               let parsed = EndLockProtectionMode(rawValue: raw) {
                return parsed
            }
            if SharedStore.pinEnabled {
                return .fourDigitPIN
            }
            return .none
        }
        set {
            SharedStore.store.set(newValue.rawValue, forKey: SharedKeys.endLockProtectionMode)
            SharedStore.pinEnabled = (newValue == .fourDigitPIN)
        }
    }

    static var isRequired: Bool {
        mode != .none
    }
}
