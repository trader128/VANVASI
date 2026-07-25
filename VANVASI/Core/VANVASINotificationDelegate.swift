import UIKit
import UserNotifications

/// Opens the intentional unlock flow when the user taps the shield follow-up notification.
final class VANVASINotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let info = response.notification.request.content.userInfo
        if let url = info["url"] as? String {
            SharedStore.store.set(url, forKey: SharedKeys.pendingUnlockURL)
        } else if let scope = info["scope"] as? String {
            SharedStore.store.set(scope, forKey: SharedKeys.pendingUnlockScope)
        }
        PendingUnlockRouter.signalPendingUnlockAvailable()
    }
}
