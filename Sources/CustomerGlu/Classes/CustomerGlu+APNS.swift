//
//  File.swift
//  
//
//  Created by Ankit Jain on 29/04/23.
//

import Foundation
import UserNotifications
import UIKit

// APNS Notification Methods
extension CustomerGlu {
    
    func setAPNToken(_ token: String) {
        apnToken = token
    }
    
    func setFCMToken(_ token: String) {
        fcmToken = token
    }
    
    @objc public func cgUserNotificationCenter(_ center: UNUserNotificationCenter,
                                               willPresent notification: UNNotification,
                                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Check if ASK is disabled, if true return else proceed.
        if let sdk_disable = CustomerGlu.sdk_disable, sdk_disable {
            return
        }
        let userInfo = notification.request.content.userInfo
        
        // Change this to your preferred presentation option
        if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            if userInfo[NotificationsKey.glu_message_type] as? String == "push" {
                
                if UIApplication.shared.applicationState == .active {
                    self.postAnalyticsEventForNotification(userInfo: userInfo as! [String:AnyHashable])
                    completionHandler([[.alert, .badge, .sound]])
                }
            }
        }
    }
    
    @objc public func cgapplication(_ application: UIApplication,
                                    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                                    backgroundAlpha: Double = 0.5,
                                    auto_close_webview: Bool = CustomerGlu.auto_close_webview ?? false,
                                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Check if ASK is disabled, if true return else proceed.
        if let sdk_disable = CustomerGlu.sdk_disable, sdk_disable {
            CustomerGlu.getInstance.printlog(cglog: "", isException: false, methodName: "CustomerGlu-cgapplication", posttoserver: true)
            return
        }
        
        // Printing message ID
        if let messageID = userInfo[gcmMessageIDKey], CustomerGlu.isDebugingEnabled  {
            print("Message ID: \(messageID)")
        }
        
        if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            
            // Record the Notification on app launch
            if isAppLaunched, userInfo[NotificationsKey.glu_message_type] as? String == NotificationsKey.in_app {
                isAppLaunched = false
                remoteNotificationUserInfo = userInfo
            }
            
            let nudge_url = userInfo[NotificationsKey.nudge_url]
            if CustomerGlu.isDebugingEnabled {
                print(nudge_url as Any)
            }
            
            let page_type = userInfo[NotificationsKey.page_type]
            
            // Setup Nudge Config
            let nudgeConfiguration = CGNudgeConfiguration()
            if(page_type != nil){
                nudgeConfiguration.layout = page_type as! String
            }
            if let absoluteHeight = userInfo[NotificationsKey.absoluteHeight] {
                nudgeConfiguration.absoluteHeight = Double(absoluteHeight as! String) ?? 0.0
            }
            if let relativeHeight = userInfo[NotificationsKey.relativeHeight] {
                nudgeConfiguration.relativeHeight = Double(relativeHeight as! String) ?? 0.0
            }
            if let closeOnDeepLink = userInfo[NotificationsKey.closeOnDeepLink] {
                nudgeConfiguration.closeOnDeepLink = Bool(closeOnDeepLink as! String) ?? CustomerGlu.auto_close_webview!
            }
            
            if userInfo[NotificationsKey.glu_message_type] as? String == NotificationsKey.in_app {
                if CustomerGlu.isDebugingEnabled {
                    print(page_type as Any)
                }
                
                var localPageType: String = CGConstants.FULL_SCREEN_NOTIFICATION
                if page_type as? String == CGConstants.BOTTOM_SHEET_NOTIFICATION {
                    localPageType = CGConstants.BOTTOM_SHEET_NOTIFICATION
                } else if ((page_type as? String == CGConstants.BOTTOM_DEFAULT_NOTIFICATION) || (page_type as? String == CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP)) {
                    localPageType = CGConstants.BOTTOM_DEFAULT_NOTIFICATION
                } else if ((page_type as? String == CGConstants.MIDDLE_NOTIFICATIONS) || (page_type as? String == CGConstants.MIDDLE_NOTIFICATIONS_POPUP)) {
                    localPageType = CGConstants.MIDDLE_NOTIFICATIONS
                }
                
                presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!,
                                                   page_type: localPageType,
                                                   backgroundAlpha: backgroundAlpha,
                                                   auto_close_webview: auto_close_webview,
                                                   nudgeConfiguration: nudgeConfiguration)
                
                self.postAnalyticsEventForNotification(userInfo: userInfo as! [String:AnyHashable])
            }
        }
    }
    
    @objc public func displayBackgroundNotification(remoteMessage: [String: AnyHashable],
                                                    auto_close_webview : Bool = CustomerGlu.auto_close_webview ?? false) {
        // Check if ASK is disabled, if true return else proceed.
        if let sdk_disable = CustomerGlu.sdk_disable, sdk_disable {
            CustomerGlu.getInstance.printlog(cglog: "", isException: false, methodName: "CustomerGlu-displayBackgroundNotification", posttoserver: false)
            return
        }
        
        if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: remoteMessage ) {
            let nudge_url = remoteMessage[NotificationsKey.nudge_url]
            if(true == CustomerGlu.isDebugingEnabled){
                print(nudge_url as Any)
            }
            
            let page_type = remoteMessage[NotificationsKey.page_type]
                        
            let nudgeConfiguration  = CGNudgeConfiguration()
            if(page_type != nil) {
                nudgeConfiguration.layout = page_type as! String
            }
            if let absoluteHeight = remoteMessage[NotificationsKey.absoluteHeight] {
                nudgeConfiguration.absoluteHeight = Double(absoluteHeight as! String) ?? 0.0
            }
            if let relativeHeight = remoteMessage[NotificationsKey.relativeHeight] {
                nudgeConfiguration.relativeHeight = Double(relativeHeight as! String) ?? 0.0
            }
            if let closeOnDeepLink = remoteMessage[NotificationsKey.closeOnDeepLink] {
                nudgeConfiguration.closeOnDeepLink = Bool(closeOnDeepLink as! String) ?? CustomerGlu.auto_close_webview!
            }
            
            if(true == CustomerGlu.isDebugingEnabled) {
                print(page_type as Any)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [self] in
                var localPageType: String = CGConstants.FULL_SCREEN_NOTIFICATION
                if page_type as? String == CGConstants.BOTTOM_SHEET_NOTIFICATION {
                    localPageType = CGConstants.BOTTOM_SHEET_NOTIFICATION
                } else if ((page_type as? String == CGConstants.BOTTOM_DEFAULT_NOTIFICATION) || (page_type as? String == CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP)) {
                    localPageType = CGConstants.BOTTOM_DEFAULT_NOTIFICATION
                } else if ((page_type as? String == CGConstants.MIDDLE_NOTIFICATIONS) || (page_type as? String == CGConstants.MIDDLE_NOTIFICATIONS_POPUP)) {
                    localPageType = CGConstants.MIDDLE_NOTIFICATIONS
                }
                
                presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!,
                                                   page_type: localPageType,
                                                   backgroundAlpha: 0.5,
                                                   auto_close_webview: auto_close_webview,
                                                   nudgeConfiguration: nudgeConfiguration)
            }
            
            self.postAnalyticsEventForNotification(userInfo: remoteMessage)
        }
    }
    
    @objc public func notificationFromCustomerGlu(remoteMessage: [String: AnyHashable]) -> Bool {
        let strType = remoteMessage[NotificationsKey.type] as? String
        return (strType == NotificationsKey.CustomerGlu) ? true : false
    }
    
    @objc func cgapplication(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        isAppLaunched = true
    }
    
    @objc func displayRecordedInAppNotification(withUserInfo userInfo: [String: AnyHashable],
                                  auto_close_webview : Bool = CustomerGlu.auto_close_webview ?? false) {
        if let remoteNotificationUserInfo {
            cgapplication(UIApplication.shared, didReceiveRemoteNotification: remoteNotificationUserInfo) { _ in
                
            }
        }
    }
}
