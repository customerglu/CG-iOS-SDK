//
//	CGAppConfig.swift
//
//	Create by Mukesh Yadav on 6/12/2022

import Foundation
import UIKit

public class CGAppConfig: Codable {
    public var data: CGConnfigData? = CGConnfigData()
    public var success: Bool? = false
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.data = try container.decodeIfPresent(CGConnfigData.self, forKey: .data) ?? CGConnfigData()
    }
    
    required public init() {
    }
}

public class CGConnfigData: Codable {
    
    public var mobile: CGMobileData?
    //    public var web: CGWeb?
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mobile = try container.decodeIfPresent(CGMobileData.self, forKey: .mobile) ?? CGMobileData()
    }
    
    required public init() {
    }
}

public class CGMobileData: Codable {
    
    public var androidStatusBarColor: String?
    public var disableSdk: Bool? = CustomerGlu.sdk_disable
    public var enableAnalytics: Bool? = CustomerGlu.analyticsEvent
    public var enableEntryPoints: Bool? = CustomerGlu.isEntryPointEnabled
    public var errorCodeForDomain: Int? = CustomerGlu.doamincode
    public var errorMessageForDomain: String? = CustomerGlu.textMsg
    public var iosSafeArea: CGIosSafeArea? = CGIosSafeArea()
    public var loadScreenColor: String? = CustomerGlu.defaultBGCollor.hexString
    public var loaderColor: String? = CustomerGlu.arrColor[0].hexString
    public var whiteListedDomains: [String]? = CustomerGlu.whiteListedDomains
    public var testUserIds: [String]? = CustomerGlu.testUsers
    public var secretKey: String? = ""
    public var enableSentry: Bool? = false
    public var forceUserRegistration: Bool? = false
    public var allowUserRegistration: Bool? = false
    public var enableDarkMode: Bool? = CustomerGlu.enableDarkMode
    public var listenToSystemDarkLightMode: Bool? = CustomerGlu.listenToSystemDarkMode
    public var lightBackground: String? = CustomerGlu.lightBackground.hexString
    public var darkBackground: String? = CustomerGlu.darkBackground.hexString
    public var loaderConfig: CGLoaderConfig? = CGLoaderConfig()
    public var androidStatusBarLightColor: String?
    public var androidStatusBarDarkColor: String?
    public var callbackConfigurationUrl: String? = ""
    public var deeplinkUrl: String? = ""
    public var isDiagnosticsEnabled: Bool = false
    public var isMetricsEnabled: Bool = true
    public var isCrashLoggingEnabled: Bool = true
    public var sentryDsn: CGSentryDSN?
    public var activityIdList: PlatformList?
    public var bannerIds: PlatformList?
    public var embedIds: PlatformList?
    public var enableMqtt: Bool?
    public var mqttEnabledComponents: [String]?
    public var allowedRetryCount: Int = 1
    public var allowAnonymousRegistration: Bool?
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.disableSdk = try container.decodeIfPresent(Bool.self, forKey: .disableSdk) ?? CustomerGlu.sdk_disable
        self.enableAnalytics = try container.decodeIfPresent(Bool.self, forKey: .enableAnalytics) ?? CustomerGlu.analyticsEvent
        self.enableEntryPoints = try container.decodeIfPresent(Bool.self, forKey: .enableEntryPoints) ?? CustomerGlu.isEntryPointEnabled
        self.errorCodeForDomain = try container.decodeIfPresent(Int.self, forKey: .errorCodeForDomain) ?? CustomerGlu.doamincode
        self.errorMessageForDomain = try container.decodeIfPresent(String.self, forKey: .errorMessageForDomain) ?? CustomerGlu.textMsg
        self.iosSafeArea = try container.decodeIfPresent(CGIosSafeArea.self, forKey: .iosSafeArea) ?? CGIosSafeArea()
        self.loadScreenColor = try container.decodeIfPresent(String.self, forKey: .loadScreenColor) ?? CustomerGlu.defaultBGCollor.hexString
        self.loaderColor = try container.decodeIfPresent(String.self, forKey: .loaderColor) ?? CustomerGlu.arrColor[0].hexString
        if let whiteListedDomains = try? container.decodeIfPresent([String].self, forKey: .whiteListedDomains) {
            self.whiteListedDomains = whiteListedDomains
        } else {
            self.whiteListedDomains = CustomerGlu.whiteListedDomains
        }
        self.secretKey = try container.decodeIfPresent(String.self, forKey: .secretKey) ?? ""
        self.enableSentry = try container.decodeIfPresent(Bool.self, forKey: .enableSentry) ?? false
        self.forceUserRegistration = try container.decodeIfPresent(Bool.self, forKey: .forceUserRegistration) ?? false
        self.allowUserRegistration = try container.decodeIfPresent(Bool.self, forKey: .allowUserRegistration) ?? false
        self.enableDarkMode = try container.decodeIfPresent(Bool.self, forKey: .enableDarkMode) ?? CustomerGlu.enableDarkMode
        self.listenToSystemDarkLightMode = try container.decodeIfPresent(Bool.self, forKey: .listenToSystemDarkLightMode) ?? CustomerGlu.listenToSystemDarkMode
        self.lightBackground = try container.decodeIfPresent(String.self, forKey: .lightBackground) ?? CustomerGlu.lightBackground.hexString
        self.darkBackground = try container.decodeIfPresent(String.self, forKey: .darkBackground) ?? CustomerGlu.darkBackground.hexString
        self.loaderConfig = try container.decodeIfPresent(CGLoaderConfig.self, forKey: .loaderConfig) ?? CGLoaderConfig()
        self.androidStatusBarDarkColor = try container.decodeIfPresent(String.self, forKey: .androidStatusBarDarkColor) ?? ""
        self.androidStatusBarLightColor = try container.decodeIfPresent(String.self, forKey: .androidStatusBarLightColor) ?? ""
        self.isDiagnosticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .isDiagnosticsEnabled) ?? false
        self.isMetricsEnabled = try container.decodeIfPresent(Bool.self, forKey: .isMetricsEnabled) ?? true
        self.isCrashLoggingEnabled = try container.decodeIfPresent(Bool.self, forKey: .isCrashLoggingEnabled) ?? true
        self.sentryDsn = try container.decodeIfPresent(CGSentryDSN.self, forKey: .sentryDsn) ?? CGSentryDSN()
        self.deeplinkUrl = try container.decodeIfPresent(String.self, forKey: .deeplinkUrl) ?? ""
        self.callbackConfigurationUrl = try container.decodeIfPresent(String.self, forKey: .callbackConfigurationUrl) ?? ""
        if let testUserIds = try? container.decodeIfPresent([String].self, forKey: .testUserIds) {
            self.testUserIds = testUserIds
        } else {
            self.testUserIds = CustomerGlu.testUsers
        }
        self.activityIdList = try container.decodeIfPresent(PlatformList.self, forKey: .activityIdList) ?? PlatformList()
        self.bannerIds = try container.decodeIfPresent(PlatformList.self, forKey: .bannerIds) ?? PlatformList()
        self.embedIds = try container.decodeIfPresent(PlatformList.self, forKey: .embedIds) ?? PlatformList()
        self.enableMqtt = try container.decodeIfPresent(Bool.self, forKey: .enableMqtt) ?? false
        if let mqttEnabledComponents = try? container.decodeIfPresent([String].self, forKey: .mqttEnabledComponents) {
            self.mqttEnabledComponents = mqttEnabledComponents
        } else {
            self.mqttEnabledComponents = []
        }
        self.allowedRetryCount = try container.decodeIfPresent(Int.self, forKey: .allowedRetryCount) ?? 1
        self.allowAnonymousRegistration = try container.decodeIfPresent(Bool.self, forKey: .allowAnonymousRegistration) ?? false
    }
    
    required public init() {
    }
}

public class CGIosSafeArea: Codable {
    
    public var bottomColor: String? = CustomerGlu.bottomSafeAreaColor.hexString
    public var bottomHeight: Int? = CustomerGlu.bottomSafeAreaHeight
    public var topColor: String? = CustomerGlu.topSafeAreaColor.hexString
    public var topHeight: Int? = CustomerGlu.topSafeAreaHeight
    public var darkTopColor: String? = CustomerGlu.topSafeAreaColor.hexString
    public var lightTopColor: String? = CustomerGlu.topSafeAreaColor.hexString
    public var lightBottomColor: String? = CustomerGlu.bottomSafeAreaColor.hexString
    public var darkBottomColor: String? = CustomerGlu.bottomSafeAreaColor.hexString
    public var newBottomHeight: Int? = CGConstants.CG_SAFE_AREA_DEFAULT
    public var newTopHeight: Int? = CGConstants.CG_SAFE_AREA_DEFAULT
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bottomColor = try container.decodeIfPresent(String.self, forKey: .bottomColor) ?? CustomerGlu.bottomSafeAreaColor.hexString
        self.bottomHeight = try container.decodeIfPresent(Int.self, forKey: .bottomHeight) ?? CustomerGlu.bottomSafeAreaHeight
        self.topColor = try container.decodeIfPresent(String.self, forKey: .topColor) ?? CustomerGlu.topSafeAreaColor.hexString
        self.topHeight = try container.decodeIfPresent(Int.self, forKey: .topHeight) ?? CustomerGlu.topSafeAreaHeight
        self.darkTopColor = try container.decodeIfPresent(String.self, forKey: .darkTopColor) ?? ""
        self.lightTopColor = try container.decodeIfPresent(String.self, forKey: .lightTopColor) ?? ""
        self.lightBottomColor = try container.decodeIfPresent(String.self, forKey: .lightBottomColor) ?? ""
        self.darkBottomColor = try container.decodeIfPresent(String.self, forKey: .darkBottomColor) ?? ""
        self.newBottomHeight = try container.decodeIfPresent(Int.self, forKey: .newBottomHeight) ?? CGConstants.CG_SAFE_AREA_DEFAULT
        self.newTopHeight = try container.decodeIfPresent(Int.self, forKey: .newTopHeight) ?? CGConstants.CG_SAFE_AREA_DEFAULT
    }
    
    required public init() {
    }
}

public class CGLoaderConfig: Codable {
    
    public var loaderURL: CGLoaderURLs? = CGLoaderURLs()
    public var embedLoaderURL: CGLoaderURLs? = CGLoaderURLs()
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.loaderURL = try container.decodeIfPresent(CGLoaderURLs.self, forKey: .loaderURL) ?? CGLoaderURLs()
        self.embedLoaderURL = try container.decodeIfPresent(CGLoaderURLs.self, forKey: .embedLoaderURL) ?? CGLoaderURLs()
    }
    
    required public init() {
    }
}

public class CGLoaderURLs: Codable {
    
    public var light: String? = ""
    public var dark: String? = ""
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.light = try container.decodeIfPresent(String.self, forKey: .light) ?? ""
        self.dark = try container.decodeIfPresent(String.self, forKey: .dark) ?? ""
    }
    
    required public init() {
    }
}

public class CGSentryDSN: Codable {
    
    public var Android: String? = ""
    public var iOS: String? = ""
    public var ReactNative: String? = ""
    public var Flutter: String? = ""
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.Android = try container.decodeIfPresent(String.self, forKey: .Android) ?? ""
        self.iOS = try container.decodeIfPresent(String.self, forKey: .iOS) ?? ""
        self.Flutter = try container.decodeIfPresent(String.self, forKey: .Flutter) ?? ""
        self.ReactNative = try container.decodeIfPresent(String.self, forKey: .ReactNative) ?? ""
    }
    
    required public init(){
        
    }
    
}
public class PlatformList: Codable {
    
    public var android: [String]?
    public var ios: [String]?

    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.android = try container.decodeIfPresent([String].self, forKey: .android) ?? [] as? [String]
        self.ios = try container.decodeIfPresent([String].self, forKey: .ios) ?? [] as? [String]
    }
    
    required public init(){
        
    }
}
