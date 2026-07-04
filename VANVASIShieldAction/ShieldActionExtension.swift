import ManagedSettings
import ManagedSettingsUI
import UserNotifications
import FamilyControls
import Foundation

class VANVASIShieldActionHandler: ShieldActionDelegate {
    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        if action == .primaryButtonPressed {
            persistAppToken(application)
        }
        respond(to: action, unlockScope: UnlockScope.singleApp.rawValue, completionHandler: completionHandler)
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        respond(to: action, unlockScope: UnlockScope.unlockAll.rawValue, completionHandler: completionHandler)
    }

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        respond(to: action, unlockScope: UnlockScope.singleApp.rawValue, completionHandler: completionHandler)
    }

    private func persistAppToken(_ token: ApplicationToken) {
        if let data = try? JSONEncoder().encode(token) {
            SharedStore.store.set(data, forKey: SharedKeys.pendingUnlockAppToken)
        }
    }

    private func respond(
        to action: ShieldAction,
        unlockScope: String,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            SharedStore.store.set(unlockScope, forKey: SharedKeys.pendingUnlockScope)
            postOpenAppNotification(scope: unlockScope)
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        case .firstSecondarySubmenuItemPressed,
             .secondSecondarySubmenuItemPressed,
             .thirdSecondarySubmenuItemPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    private func postOpenAppNotification(scope: String) {
        let content = UNMutableNotificationContent()
        content.title = "VANVASI"
        content.body = "Tap to unlock with intention"
        content.sound = .default
        content.userInfo = ["scope": scope, "url": VANVASIConfig.unlockURL(
            scope: scope == UnlockScope.unlockAll.rawValue ? .unlockAll : .singleApp
        ).absoluteString]
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
