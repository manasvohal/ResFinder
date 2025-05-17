import UIKit
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // 1) Configure Firebase
        FirebaseApp.configure()
        
        // 2) Request notification permissions
        NotificationManager.shared.requestAuthorization()
        
        return true
    }
}
