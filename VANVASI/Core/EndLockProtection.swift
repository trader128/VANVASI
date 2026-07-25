import Foundation
import LocalAuthentication

@MainActor
enum EndLockProtection {
    static var mode: EndLockProtectionMode {
        get { EndLockProtectionStore.mode }
        set { EndLockProtectionStore.mode = newValue }
    }

    static var isRequired: Bool { EndLockProtectionStore.isRequired }

    static func authenticateSystem() async -> Bool {
        await authenticate(for: mode)
    }

    static func authenticate(for mode: EndLockProtectionMode) async -> Bool {
        switch mode {
        case .none:
            return true
        case .fourDigitPIN:
            return false
        case .faceID:
            return await evaluate(
                policy: .deviceOwnerAuthenticationWithBiometrics,
                reason: "Confirm to turn off monk mode"
            )
        case .devicePasscode:
            return await evaluate(
                policy: .deviceOwnerAuthentication,
                reason: "Confirm to turn off monk mode"
            )
        }
    }

    static func isAvailable(_ mode: EndLockProtectionMode) -> Bool {
        let context = LAContext()
        var error: NSError?
        switch mode {
        case .none, .fourDigitPIN:
            return true
        case .faceID:
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        case .devicePasscode:
            return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        }
    }

    static func setMode(_ newMode: EndLockProtectionMode, pin: String? = nil) -> String? {
        switch newMode {
        case .none:
            PINProtection.clearPINWithoutVerification()
            mode = .none
            return nil
        case .fourDigitPIN:
            guard let pin, PINProtection.setPIN(pin) else {
                return "Use at least 4 digits."
            }
            mode = .fourDigitPIN
            return nil
        case .faceID, .devicePasscode:
            mode = newMode
            return nil
        }
    }

    static func disableProtection(currentPIN: String?) -> Bool {
        switch mode {
        case .none:
            return true
        case .fourDigitPIN:
            guard let currentPIN, PINProtection.removePIN(currentPIN: currentPIN) else {
                return false
            }
            mode = .none
            return true
        case .faceID, .devicePasscode:
            mode = .none
            return true
        }
    }

    private static func evaluate(policy: LAPolicy, reason: String) async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        var error: NSError?
        guard context.canEvaluatePolicy(policy, error: &error) else {
            return false
        }
        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(policy, localizedReason: reason) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
}
