//
//  File.swift
//  
//
//  Created by hitesh on 28/10/21.
//

import Foundation
import UIKit

class ApplicationManager {
    public static var baseUrl = "api.customerglu.com/"
    public static var devbaseUrl = "dev-api.customerglu.com/"
    public static var streamUrl = "stream.customerglu.com/"
    public static var eventUrl = "events.customerglu.com/"
    public static var analyticsUrl = "analytics.customerglu.com/"
    public static var diagnosticUrl = "diagnostics.customerglu.com/"
    public static var accessToken: String?
    public static var operationQueue = OperationQueue()
    public static var appSessionId = UUID().uuidString
    
    public static func openWalletApi(completion: @escaping (Bool, CGCampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            return
        }
        var eventData: [String: Any] = [:]
        var token: String? = ""
        if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil {
              eventData["token"] = token
        } else {
            eventData["token"] = token

        }
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_LOAD_CAMPAIGN_START, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        APIManager.getWalletRewards(queryParameters: [:]) { result in
            switch result {
            case .success(let response):
                // Save this - To open / not open wallet incase of failure / invalid campaignId in loadCampaignById
                CustomerGlu.getInstance.setCampaignsModel(response)
                completion(true, response)
                
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "ApplicationManager-openWalletApi", posttoserver: true)
                completion(false, nil)
            }
        }
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_LOAD_CAMPAIGN_END, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
    }
    
    public static func loadAllCampaignsApi(type: String, value: String, loadByparams: NSDictionary, completion: @escaping (Bool, CGCampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            return
        }
        
        var params = [String: AnyHashable]()
        
        if loadByparams.count != 0 {
            params = (loadByparams as? [String: AnyHashable] ?? [:])
        } else {
            if type != "" {
                params[type] = value
            }
        }
        
        APIManager.getWalletRewards(queryParameters: params as NSDictionary) { result in
            switch result {
            case .success(let response):
                // Save this - To open / not open wallet incase of failure / invalid campaignId in loadCampaignById
                CustomerGlu.getInstance.setCampaignsModel(response)
                completion(true, response)
                
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "ApplicationManager-loadAllCampaignsApi", posttoserver: true)
                completion(false, nil)
            }
        }
    }
    
    public static func sendEventData(eventName: String, eventProperties: [String: Any]?, completion: @escaping (Bool, CGAddCartModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            return
        }
        let event_id = UUID().uuidString
        let timestamp = fetchTimeStamp(dateFormat: CGConstants.DATE_FORMAT)
        let user_id = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID)
        
        let eventData = [
            APIParameterKey.event_id: event_id,
            APIParameterKey.event_name: eventName,
            APIParameterKey.user_id: user_id,
            APIParameterKey.timestamp: timestamp,
            APIParameterKey.event_properties: eventProperties ?? [String: Any]()] as [String: Any]
        
        APIManager.addToCart(queryParameters: eventData as NSDictionary) { result in
            switch result {
            case .success(let response):
                completion(true, response)
                
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "ApplicationManager-sendEventData", posttoserver: true)
                completion(false, nil)
            }
        }
    }
    
    public static func callCrashReport(cglog: String = "", isException: Bool = false, methodName: String = "", user_id: String) {
        if user_id.count < 0 {
            return
        }
        if CustomerGlu.sdk_disable != true {
            CGSentryHelper.shared.captureExceptionEvent(exceptionLog: cglog)
        }
        // Removed the crash event old implementation

    }
    
    public static func sendEventsDiagnostics(eventLogType: String,eventName: String,eventMeta:[String:Any],completion: @escaping(Bool, CGAddCartModel?) -> Void){
        var params: [String: Any] = [:]
        
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let osName = UIDevice.current.systemName
        let udid = UUID().uuidString
        let timestamp = Date.currentTimeStamp
        let eventId = UUID().uuidString
        
        
        // Other fields in the Analytics
        params["analytics_version"] = "4.0.0"
        params["event_id"] = eventId
        params["event_name"] = eventName
        params["log_type"] = eventLogType
        params["sdk_version"] = CustomerGlu.sdk_version
        params["session_time"] = timestamp
        params["timestamp"] = timestamp
        params["type"] = "SYSTEM"
        params["user_id"] = UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_USERID)  ?? ""
        
        
        var platformDetails: [String: Any] = [:]
        platformDetails["manufacturer"] = "Apple"
        platformDetails["model"] = deviceModel
        platformDetails["os"] = "iOS"
        platformDetails["os_version"] = systemVersion
        params["platformDetails"] = platformDetails
        
        APIManager.sendEventsDiagnostics(queryParameters:params as NSDictionary, completion:{ result in
            switch(result) {
            case .success(let response):
                completion(true, response)
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "ApplicationManager-crashReport", posttoserver: false)
                completion(false, nil)
            }
        })
    }
    
    private static func crashReport(parameters: NSDictionary, completion: @escaping (Bool, CGAddCartModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            
            return
        }
        APIManager.crashReport(queryParameters: parameters) { result in
            switch result {
            case .success(let response):
                completion(true, response)
                
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "ApplicationManager-crashReport", posttoserver: false)
                completion(false, nil)
            }
        }
    }
    
    public static func doValidateToken() -> Bool {
        if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil {
            let arr = JWTDecode.shared.decode(jwtToken: CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN))
            let expTime = Date(timeIntervalSince1970: (arr["exp"] as? Double ?? 0))
            let currentDateTime = Date()
            if currentDateTime < expTime {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    public static func isAnonymousUesr() -> Bool {
        if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil {
            let arr = JWTDecode.shared.decode(jwtToken: CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN))
            let userId = arr[APIParameterKey.userId] as? String
            let anonymousId = arr[APIParameterKey.anonymousId] as? String
            
            if(userId != nil && anonymousId != nil && userId!.count > 0 && anonymousId!.count > 0 && userId == anonymousId){
                return true
            }
        }
        return false
    }
    
    public static func sendAnalyticsEvent(eventNudge: [String: Any], completion: @escaping (Bool, CGAddCartModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            return
        }
        
        var eventInfo = eventNudge
        
        eventInfo[APIParameterKey.analytics_version] = APIParameterKey.analytics_version_value
        eventInfo[APIParameterKey.event_id] = UUID().uuidString
        eventInfo[APIParameterKey.user_id] = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID)
        eventInfo[APIParameterKey.timestamp] = ApplicationManager.fetchTimeStamp(dateFormat: CGConstants.DATE_FORMAT)
        eventInfo[APIParameterKey.type] = "track"
        
        var platform_details = [String: String]()
        platform_details[APIParameterKey.device_type] = "MOBILE"
        platform_details[APIParameterKey.os] = "IOS"
        platform_details[APIParameterKey.app_platform] = CustomerGlu.app_platform
        platform_details[APIParameterKey.sdk_version] = CustomerGlu.sdk_version
        eventInfo[APIParameterKey.platform_details] = platform_details
        
        
        APIManager.sendAnalyticsEvent(queryParameters: eventInfo as NSDictionary) { result in
            switch result {
            case .success(let response):
                completion(true, response)
                
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "ApplicationManager-sendAnalyticsEvent", posttoserver: true)
                completion(false, nil)
            }
        }
    }
    
    
    public static func fetchTimeStamp(dateFormat: String) -> String {
        let date = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = dateFormat
        return dateformatter.string(from: date)
    }
}
