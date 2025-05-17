import Foundation
import UserNotifications
import UIKit

final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private override init() { super.init() }
    
    /// Ask the user for permission to send alerts, badges, sounds
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, err in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            } else {
                print("Notifications permission denied:", err ?? "")
            }
        }
    }
    
    /// Schedule a one-off notification `days` days from now.
    /// Embeds the outreach document ID so we can deep-link back.
    func scheduleFollowUp(for recordId: String, professorName: String, days: Double = 7) {
        let content = UNMutableNotificationContent()
        content.title = "Follow up with \(professorName)"
        content.body  = "It's been \(Int(days)) days—tap to send your follow-up email."
        content.userInfo = ["recordId": recordId]
        content.sound = .default

        let interval = max(1, TimeInterval(days * 24 * 60 * 60))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: "followUp_\(recordId)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { err in
            if let err = err {
                print("⚠️ Failed to schedule notification:", err)
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let recordId = response.notification.request.content.userInfo["recordId"] as? String {
            let url = URL(string: "resfinder://followup?recordId=\(recordId)")!
            UIApplication.shared.open(url)
        }
        completionHandler()
    }
}
