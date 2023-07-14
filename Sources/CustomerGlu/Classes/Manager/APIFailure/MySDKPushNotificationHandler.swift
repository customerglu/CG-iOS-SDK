//
//  MySDKPushNotificationHandler.swift
//  
//
//  Created by Yasir on 14/07/23.
//

import UIKit
import UserNotifications

class MySDKPushNotificationHandler: NSObject, UNUserNotificationCenterDelegate {

    static let shared = MySDKPushNotificationHandler()

    private override init() {
        super.init()
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                // Handle denial of notification permission
            }
        }
    }

    func applicationDidFinishLaunching() {
        // Call this method from the SDK's entry point, such as when the SDK initializes

        // Register for remote notifications
        registerForPushNotifications()
    }

    // Handle remote notification registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token:", token)
        // Send the device token to your server for further processing
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications:", error.localizedDescription)
    }

    // Handle incoming remote notifications while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Customize how the notification is displayed (e.g., show an alert, play a sound, etc.)
        completionHandler([.alert, .sound])
    }

    // Handle tapping on the notification when the app is in the foreground or background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification response here
        completionHandler()
    }
}
