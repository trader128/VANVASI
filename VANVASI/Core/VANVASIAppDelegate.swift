import UIKit
import UserNotifications

final class VANVASIAppDelegate: NSObject, UIApplicationDelegate {
    private let notificationDelegate = VANVASINotificationDelegate()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        return true
    }
}
