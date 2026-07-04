import AppIntents
import Foundation

struct EnableVANVASILockIntent: AppIntent {
    static var title: LocalizedStringResource = "Enable VANVASI Lock"
    static var description = IntentDescription("Turn on monk mode — calls and messages only.")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult {
        let manager = MonkLockManager.shared
        if !manager.isLockEnabled {
            _ = manager.enableLock(logEvent: false)
        }
        return .result()
    }
}

struct DisableVANVASILockIntent: AppIntent {
    static var title: LocalizedStringResource = "Disable VANVASI Lock"
    static var description = IntentDescription("Turn off monk mode and remove all shields.")
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        if !SharedStore.pinEnabled {
            MonkLockManager.shared.disableLock(requirePIN: false)
        }
        return .result()
    }
}

struct ToggleVANVASILockIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle VANVASI Lock"
    static var description = IntentDescription("Switch monk mode on or off.")
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        let manager = MonkLockManager.shared
        if manager.isLockEnabled {
            if !SharedStore.pinEnabled {
                manager.disableLock(requirePIN: false)
            }
        } else {
            _ = manager.enableLock(logEvent: false)
        }
        return .result()
    }
}

struct VANVASIAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: EnableVANVASILockIntent(),
            phrases: [
                "Enable \(.applicationName) lock",
                "Turn on monk mode with \(.applicationName)"
            ],
            shortTitle: "Enable Lock",
            systemImageName: "lock.fill"
        )
        AppShortcut(
            intent: DisableVANVASILockIntent(),
            phrases: [
                "Disable \(.applicationName) lock",
                "Turn off monk mode with \(.applicationName)"
            ],
            shortTitle: "Disable Lock",
            systemImageName: "lock.open"
        )
        AppShortcut(
            intent: ToggleVANVASILockIntent(),
            phrases: ["Toggle \(.applicationName) lock"],
            shortTitle: "Toggle Lock",
            systemImageName: "lock.rotation"
        )
    }
}
