//
//  File.swift
//  
//
//  Created by Kausthubh adhikari on 23/12/22.
//

import Foundation
import Sentry

public class CGSentryHelper{
    
    static let shared = CGSentryHelper()
    
    func setupSentry(){
        if CustomerGlu.sentry_enable! {
            SentrySDK.start { options in
                options.dsn = CustomerGlu.sentryDSN
                options.beforeSend = { event in
                    if event.level == SentryLevel.fatal {
                        var eventData: [String: Any] = [:]
                        eventData["stack_trace"] = event
                        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_TYPE_CRASH, eventType:CGDiagnosticConstants.CG_TYPE_CRASH, eventMeta:eventData)                    }
                    return event
                }
            }
        }
    }
    
    func setupUser(userId: String, clientId: String, cgappplatform: String = CustomerGlu.app_platform, cgsdkversion:String = CustomerGlu.sdk_version){
        if CustomerGlu.sentry_enable! {
            let user = User()
            user.userId = userId
            user.username = clientId
            SentrySDK.setUser(user)
            SentrySDK.configureScope { scope in
                scope.setContext(value: [
                    "cg-app-platform": cgappplatform,
                    "cg-sdk-version" : cgsdkversion
                ], key: "sdkdetails")
            }
        }
    }
    
    func logoutSentryUser(){
        if CustomerGlu.sentry_enable! {
            SentrySDK.setUser(nil)
        }
    }
    
    func captureExceptionEvent(exceptionLog: String){
        if CustomerGlu.sentry_enable! {
            let exception =  NSError(domain: exceptionLog, code: 0, userInfo: nil)
            SentrySDK.capture(error: exception)
        }
    }
    
    
    
}
