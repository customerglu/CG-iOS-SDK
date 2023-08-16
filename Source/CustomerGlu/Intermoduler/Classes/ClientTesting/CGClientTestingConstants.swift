//
//  File.swift
//
//
//  Created by Ankit Jain on 21/04/23.
//

import Foundation

// MARK: - CGClientTestingStatus
public enum CGClientTestingStatus: Int {
    case header
    case pending
    case success
    case failure
    
    func getStatusForSDKTestStepsAPI() -> String {
        switch self {
        case .success:
            return "SUCCESS"
        default:
            return "FAILURE"
        }
    }
}

// MARK: - CGCustomAlertTag
public enum CGCustomAlertTag: Int {
    case callbackHandingTag = 1001
    case nudgeHandlingTag = 1002
    case cgDeeplinkHandlingTag = 1003
}

// MARK: - CGClientTestingRowItem
public enum CGClientTestingRowItem {
    case basicIntegration(status: CGClientTestingStatus)
    case sdkInitialised(status: CGClientTestingStatus)
    case userRegistered(status: CGClientTestingStatus)
    case callbackHanding(status: CGClientTestingStatus)
    case advanceIntegration(status: CGClientTestingStatus)
    case firebaseSetup(status: CGClientTestingStatus)
    case firebaseToken(status: CGClientTestingStatus)
    case firebaseServerKey(status: CGClientTestingStatus)
    case apnsDeviceToken(status: CGClientTestingStatus)
    case privateKeyApns(status: CGClientTestingStatus)
    case nudgeHandling(status: CGClientTestingStatus)
    case cgDeeplinkHandling(status: CGClientTestingStatus)
    case entryPointSetup(status: CGClientTestingStatus)
    case entryPointScreeNameSetup(status: CGClientTestingStatus)
    case entryPointBannerIDSetup(status: CGClientTestingStatus)
    case entryPointEmbedIDSetup(status: CGClientTestingStatus)
    
    func getTitle() -> String {
        switch self {
        case .basicIntegration:
            return "Basic Integration"
        case .sdkInitialised:
            return "SDK Initialised"
        case .userRegistered:
            return "User Registered"
        case .callbackHanding:
            return "Callback Handing"
        case .advanceIntegration:
            return "Advance Integration"
        case .firebaseSetup:
            return "Firebase Setup"
        case .firebaseToken:
            return "Firebase Token"
        case .firebaseServerKey:
            return "Firebase Server Key Setup"
        case .apnsDeviceToken:
            return "APNS Setup"
        case .privateKeyApns:
            return "APNS Server Key Setup"
        case .nudgeHandling:
            return "Nudge Handling"
        case .cgDeeplinkHandling:
            return "CG Deeplink Handling"
        case .entryPointSetup:
            return "EntryPoint Setup"
        case .entryPointScreeNameSetup:
            return "ScreenName Setup"
        case .entryPointBannerIDSetup:
            return "BannerId Set up"
        case .entryPointEmbedIDSetup:
            return "EmbedId Set up"
        }
    }
    
    func isSubTask() -> Bool {
        switch self {
        case .firebaseToken, .firebaseServerKey, .apnsDeviceToken, .privateKeyApns, .entryPointScreeNameSetup, .entryPointBannerIDSetup, .entryPointEmbedIDSetup:
            return true
        default:
            return false
        }
    }
    
    func getStatus() -> CGClientTestingStatus {
        switch self {
        case .basicIntegration(let status):
            return status
        case .sdkInitialised(let status):
            return status
        case .userRegistered(let status):
            return status
        case .callbackHanding(let status):
            return status
        case .advanceIntegration(let status):
            return status
        case .firebaseSetup(let status):
            return status
        case .firebaseToken(let status):
            return status
        case .firebaseServerKey(let status):
            return status
        case .apnsDeviceToken(let status):
            return status
        case .privateKeyApns(let status):
            return status
        case .nudgeHandling(let status):
            return status
        case .cgDeeplinkHandling(let status):
            return status
        case .entryPointSetup(let status):
            return status
        case .entryPointScreeNameSetup(let status):
            return status
        case .entryPointBannerIDSetup(let status):
            return status
        case .entryPointEmbedIDSetup(let status):
            return status
        }
    }
    
    func getAlertTitleAndMessage() -> (title: String, message: String, tag: Int)? {
        switch self {
        case .basicIntegration:
            return nil
        case .sdkInitialised:
            return nil
        case .userRegistered:
            return nil
        case .callbackHanding:
            if let callbackConfigurationUrl = CustomerGlu.getInstance.appconfigdata?.callbackConfigurationUrl {
                return ("CustomerGlu", "Following button contains \(callbackConfigurationUrl)", CGCustomAlertTag.callbackHandingTag.rawValue)
            } else {
                return nil
            }
        case .advanceIntegration:
            return nil
        case .firebaseSetup:
            return nil
        case .firebaseToken:
            return nil
        case .firebaseServerKey:
            return nil
        case .apnsDeviceToken:
            return nil
        case .privateKeyApns:
            return nil
        case .nudgeHandling:
            return ("CustomerGlu", "Do you see a nudge?", CGCustomAlertTag.nudgeHandlingTag.rawValue)
        case .cgDeeplinkHandling:
            return ("CustomerGlu", "Has CG Deeplink successfully redirected?", CGCustomAlertTag.cgDeeplinkHandlingTag.rawValue)
        case .entryPointSetup:
            return nil
        case .entryPointScreeNameSetup:
            return nil
        case .entryPointBannerIDSetup:
            return nil
        case .entryPointEmbedIDSetup:
            return nil
        }
    }
    
    func getDocumentationURL() -> URL? {
        switch self {
        case .basicIntegration:
            return nil
        case .sdkInitialised:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#initialise-sdk")
        case .userRegistered:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#register-user-mandatory")
        case .callbackHanding:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#handling-events")
        case .advanceIntegration:
            return nil
        case .firebaseSetup:
            return nil
        case .firebaseToken:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#register-user-mandatory")
        case .firebaseServerKey:
            return URL(string: "https://docs.customerglu.com/advanced-topics/notifications#firebase-cloud-messaging-fcm")
        case .apnsDeviceToken:
            return nil
        case .privateKeyApns:
            return nil
        case .nudgeHandling:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#handle-customerglu-nudges")
        case .cgDeeplinkHandling:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#handling-customerglu-deeplinks")
        case .entryPointSetup:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#enable-entry-points")
        case .entryPointScreeNameSetup:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#setting-up-floating-buttons-and-popups")
        case .entryPointBannerIDSetup:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#setting-up-banners")
        case .entryPointEmbedIDSetup:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#setting-up-embed-view")
        }
    }
    
    func getSDKTestStepName() -> String {
        switch self {
        case .basicIntegration:
            return ""
        case .sdkInitialised:
            return "SDK_INITIALIZED"
        case .userRegistered:
            return "USER_REGISTERED"
        case .callbackHanding:
            return "CALLBACK_HANDLING"
        case .advanceIntegration:
            return ""
        case .firebaseSetup:
            return ""
        case .firebaseToken:
            return "FIREBASE_TOKEN_SHARED"
        case .firebaseServerKey:
            return "FIREBASE_PRIVATE_KEY"
        case .apnsDeviceToken:
            return "APNS_TOKEN_SHARED"
        case .privateKeyApns:
            return "APNS_PRIVATE_KEY"
        case .nudgeHandling:
            return "NUDGE_HANDLING"
        case .cgDeeplinkHandling:
            return "ONELINK_HANDLING"
        case .entryPointSetup:
            return "ENTRYPOINTS_SET_UP"
        case .entryPointScreeNameSetup:
            return "ENTRYPOINTS_SCREENNAME_SET_UP"
        case .entryPointBannerIDSetup:
            return "ENTRYPOINTS_BANNERID_SET_UP"
        case .entryPointEmbedIDSetup:
            return "ENTRYPOINTS_EMBEDID_SET_UP"
        }
    }
}

// MARK: - CGSDKTestStepsModel
struct CGSDKTestStepsModel {
    var name: CGClientTestingRowItem?
    var status: CGClientTestingStatus? // Should hold only success or failure
    var date: Date = Date() // Whenever model is initialised the timestamp will be recorded.
    
    func asDictionary() -> [String: Any] {
        var data: [String: Any] = [:]
        if let name {
            data["name"] = name.getSDKTestStepName()
        }
        if let status {
            data["status"] = status.getStatusForSDKTestStepsAPI()
        }
        data["timestamp"] = fetchTimeStamp()
        return data
    }
    
    private func fetchTimeStamp() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = CGConstants.DATE_FORMAT
        return dateformatter.string(from: date)
    }
}
