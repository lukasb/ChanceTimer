import SwiftUI
import UserNotifications

// Notification Manager that conforms to UNUserNotificationCenterDelegate
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // This will present the notification as an alert and play the sound when the app is in the foreground
        completionHandler([.banner, .sound])
    }
}

@main
struct ChanceTimerApp: App {
    // Initialize the notification manager
    let notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Additional setup if needed, the delegate is already set in the manager's init
                }
        }
    }
}
