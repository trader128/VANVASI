import Foundation
import FamilyControls

extension FamilyActivitySelection {
    /// Apps the user marked as always free (Phone, Messages, VANVASI, …).
    var allowedAppCount: Int { applicationTokens.count }

    var isValidAllowlist: Bool {
        !applicationTokens.isEmpty
    }
}

enum LockManagerError: LocalizedError {
    case noAppsSelected
    case authorizationDenied
    case shieldApplyFailed

    var errorDescription: String? {
        switch self {
        case .noAppsSelected:
            return "Select at least Phone, Messages, and VANVASI in the list above."
        case .authorizationDenied:
            return "Screen Time permission is required. Grant access first."
        case .shieldApplyFailed:
            return "Could not apply lock. Try again or restart the app."
        }
    }
}
