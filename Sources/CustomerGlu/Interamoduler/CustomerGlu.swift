import Foundation
import SwiftUI
import UIKit
import Lottie

let gcmMessageIDKey = "gcm.message_id"

struct EntryPointPopUpModel: Codable {
    public var popups: [PopUpModel]?
}

@objc(CGSTATE)
public enum CGSTATE:Int {
    case     SUCCESS,
             USER_NOT_SIGNED_IN,
             INVALID_URL,
             INVALID_CAMPAIGN,
             CAMPAIGN_UNAVAILABLE,
             NETWORK_EXCEPTION,
             DEEPLINK_URL,
             EXCEPTION
}

struct PopUpModel: Codable {
    public var _id: String?
    public var showcount: CGShowCount?
    public var delay: Int?
    public var backgroundopacity: Double?
    public var priority: Int?
    public var popupdate: Date?
    public var type: String?
}

@objc(CGDeeplinkURLType)
public enum CGDeeplinkURLType: Int {
    case link,
         wallet,
         campaign
}

@objc(CustomerGlu)

public class CustomerGlu: NSObject, CustomerGluCrashDelegate {
    
    // MARK: - Global Variable
    var spinner = SpinnerView()
    var progressView = LottieAnimationView()
    var arrFloatingButton = [FloatingButtonController]()
    
    // Singleton Instance
    @objc public static var getInstance = CustomerGlu()
    public static var sdk_disable: Bool? = false
    public static var sentryDSN: String = CGConstants.CGSENTRYDSN
    public static var isDiagnosticsEnabled: Bool? = false
    public static var isMetricsEnabled: Bool? = true
    public static var isCrashLogsEnabled: Bool? = true
    public static var sentry_enable: Bool? = false
    public static var enableDarkMode: Bool? = false
    public static var listenToSystemDarkMode: Bool? = false
    @objc public static var fcm_apn = ""
    public static var analyticsEvent: Bool? = false
    let userDefaults = UserDefaults.standard
    @objc public var apnToken = ""
    @objc public var fcmToken = ""
    @objc public static var defaultBannerUrl = ""
    @objc public static var arrColor = [UIColor(red: (101/255), green: (220/255), blue: (171/255), alpha: 1.0)]
    public static var auto_close_webview: Bool? = false
    @objc public static var topSafeAreaHeight = 44
    @objc public static var bottomSafeAreaHeight = 34
    @objc public static var topSafeAreaColor = UIColor.white
    @objc public static var bottomSafeAreaColor = UIColor.white
    @objc public static var topSafeAreaColorLight = UIColor.white
    @objc public static var topSafeAreaColorDark = UIColor.black
    @objc public static var bottomSafeAreaColorDark = UIColor.black
    @objc public static var bottomSafeAreaColorLight = UIColor.white
    public static var entryPointdata: [CGData] = []
    @objc public static var isDebugingEnabled = false
    @objc public static var isEntryPointEnabled = false
    @objc public static var activeViewController = ""
    @objc public static var app_platform = "IOS"
    @objc public static var defaultBGCollor = UIColor.white
    @objc public static var lightBackground = UIColor.white
    @objc public static var darkBackground = UIColor.black
    @objc public static var sdk_version = APIParameterKey.cgsdkversionvalue
    
    internal var activescreenname = ""
    public static var bannersHeight: [String: Any]? = nil
    public static var embedsHeight: [String: Any]? = nil
    
    internal var appconfigdata: CGMobileData? = nil
    internal var popupDict = [PopUpModel]()
    internal var entryPointPopUpModel = EntryPointPopUpModel()
    internal var popupDisplayScreens = [String]()
    private var configScreens = [String]()
    private var popuptimer : Timer?
    private var delaySeconds: Double = 0
    public static var whiteListedDomains = [CGConstants.default_whitelist_doamin]
    public static var testUsers = [String]()
    public static var activityIdList = [String]()
    public static var bannerIds = [String]()
    public static var embedIds = [String]()
    public static var doamincode = 404
    public static var textMsg = "Requested-page-is-not-valid"
    public static var lightLoaderURL = ""
    public static var darkLoaderURL = ""
    public static var lightEmbedLoaderURL = ""
    public static var darkEmbedLoaderURL = ""
    @objc public var cgUserData = CGUser()
    private var sdkInitialized: Bool = false
    private static var isAnonymousFlowAllowed: Bool = false
    
    private var allowOpenWallet: Bool = true
    private var loadCampaignResponse: CGCampaignsModel?
    
    internal static var sdkWriteKey: String = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String ?? ""
    
    private override init() {
        super.init()
        
        migrateUserDefaultKey()
        
        if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil {
            if CustomerGlu.isEntryPointEnabled {
                getEntryPointData()
            }
        }
        
        let jsonString = decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERDATA)
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            if(jsonData.count > 0){
                cgUserData = try decoder.decode(CGUser.self, from: jsonData)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        CustomerGluCrash.add(delegate: self)
        
        if userDefaults.object(forKey: CGConstants.CustomerGluCrash) != nil {
            let jsonString = decryptUserDefaultKey(userdefaultKey: CGConstants.CustomerGluCrash)
            let jsonData = Data(jsonString.utf8)
            do {
                let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
                
                // you can now cast it with the right type
                if let crashItems = decoded as? [String: Any] {
                    // use dictFromJSON
                    ApplicationManager.callCrashReport(cglog: (crashItems["callStack"] as? String)!, isException: true, methodName: "CustomerGluCrash", user_id: decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID))
                }
            } catch {
                if CustomerGlu.isDebugingEnabled {
                    print("private override init()")
                }
            }
        }
    }
    
    @objc public func gluSDKDebuggingMode(enabled: Bool) {
        CustomerGlu.isDebugingEnabled = enabled
    }
    
    @objc public func enableEntryPoints(enabled: Bool) {
        CustomerGlu.isEntryPointEnabled = enabled
        if CustomerGlu.isEntryPointEnabled {
            getEntryPointData()
        }
    }
    
    @objc public func allowAnonymousRegistration(enabled: Bool) {
        CustomerGlu.isAnonymousFlowAllowed = enabled
    }
    
    @objc public func allowAnonymousRegistration() -> Bool {
        CustomerGlu.isAnonymousFlowAllowed
    }
    
    @objc public func customerGluDidCatchCrash(with model: CrashModel) {
        
        CustomerGlu.getInstance.printlog(cglog: "\(model)", isException: false, methodName: "CustomerGlu-customerGluDidCatchCrash-1", posttoserver: false)
        let dict = [
            "name": model.name ?? "",
            "reason": model.reason ?? "",
            "appinfo": model.appinfo ?? "",
            "callStack": model.callStack ?? ""] as [String: Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            let jsonString2 = String(data: jsonData, encoding: .utf8) ?? ""
            encryptUserDefaultKey(str: jsonString2, userdefaultKey: CGConstants.CustomerGluCrash)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc public func disableGluSdk(disable: Bool) {
        var eventData: [String: Any] = [:]
        eventData["disableGluSdk"] = disable
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_DISABLE_SDK_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        CustomerGlu.sdk_disable = disable
    }
    
    @objc public func enableDarkMode(isDarkModeEnabled: Bool){
        var eventData: [String: Any] = [:]
        eventData["enableDarkMode"] = isDarkModeEnabled
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_SET_DARK_MODE_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        CustomerGlu.enableDarkMode = isDarkModeEnabled
    }
    
    @objc public func isDarkModeEnabled()-> Bool {
        return CustomerGlu.getInstance.checkIsDarkMode()
    }
    
    @objc public func listenToDarkMode(allowToListenDarkMode: Bool){
        var eventData: [String: Any] = [:]
        eventData["listenToDarkMode"] = listenToDarkMode
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_LISTEN_SYSTEM_DARK_MODE_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        CustomerGlu.listenToSystemDarkMode = allowToListenDarkMode
    }
    
    @objc public func isFcmApn(fcmApn: String) {
        CustomerGlu.fcm_apn = fcmApn
    }
    
    @objc public func setDefaultBannerImage(bannerUrl: String) {
        CustomerGlu.defaultBannerUrl = bannerUrl
    }
    
    @objc public func configureLoaderColour(color: [UIColor]) {
        var eventData: [String: Any] = [:]
        eventData["loaderColor"] = color
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_LOADER_COLOR_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        CustomerGlu.arrColor = color
    }
    @objc public func configureLoadingScreenColor(color: UIColor) {
        CustomerGlu.defaultBGCollor = color
    }
    @objc public func configureLightBackgroundColor(color: UIColor) {
        CustomerGlu.lightBackground = color
    }
    @objc public func configureDarkBackgroundColor(color: UIColor) {
        CustomerGlu.darkBackground = color
    }
    
    internal func checkIsDarkMode() -> Bool{
        
        if (true == CustomerGlu.enableDarkMode){
            return true
        }else{
            if(true == CustomerGlu.listenToSystemDarkMode){
                if #available(iOS 12.0, *) {
                    if let controller = topMostController() {
                        if controller.traitCollection.userInterfaceStyle == .dark {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    func loaderShow(withcoordinate x: CGFloat, y: CGFloat, isembedview:Bool = false) {
        DispatchQueue.main.async { [self] in
            if let controller = topMostController() {
                controller.view.isUserInteractionEnabled = false
                
                var path_key = ""
                if isembedview {
                    if checkIsDarkMode() {
                        path_key = CGConstants.CUSTOMERGLU_DARK_EMBEDLOTTIE_FILE_PATH
                    } else {
                        path_key = CGConstants.CUSTOMERGLU_LIGHT_EMBEDLOTTIE_FILE_PATH
                    }
                } else {
                    if checkIsDarkMode() {
                        path_key = CGConstants.CUSTOMERGLU_DARK_LOTTIE_FILE_PATH
                    } else {
                        path_key = CGConstants.CUSTOMERGLU_LIGHT_LOTTIE_FILE_PATH
                    }
                }

                let path = decryptUserDefaultKey(userdefaultKey: path_key)
                progressView.removeFromSuperview()
                spinner.removeFromSuperview()
                
                if path.count > 0 && URL(string: path) != nil && path.hasSuffix(".json") {
                    progressView = LottieAnimationView(filePath: decryptUserDefaultKey(userdefaultKey: path_key))
                    
                    let size = (UIScreen.main.bounds.width <= UIScreen.main.bounds.height) ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
                    
                    progressView.frame = CGRect(x: x-(size/2), y: y-(size/2), width: size, height: size)
                    progressView.contentMode = .scaleAspectFit
                    progressView.loopMode = .loop
                    progressView.play()
                    controller.view.addSubview(progressView)
                    controller.view.bringSubviewToFront(progressView)
                } else {
                    spinner = SpinnerView(frame: CGRect(x: x-30, y: y-30, width: 60, height: 60))
                    controller.view.addSubview(spinner)
                    controller.view.bringSubviewToFront(spinner)
                }
            }
        }
    }
    
    @objc public func getReferralId(deepLink: URL) -> String {
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        let referrerUserId = queryItems?.filter({(item) in item.name == APIParameterKey.userId}).first?.value
        return referrerUserId ?? ""
    }
    
    @objc public func closeWebviewOnDeeplinkEvent(close: Bool) {
        CustomerGlu.auto_close_webview = close
    }
    
    @objc public func enableAnalyticsEvent(event: Bool) {
        var eventData: [String: Any] = [:]
        eventData["enableAnalyticsEvent"] = event
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_ENABLE_ANALYTICS_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        CustomerGlu.analyticsEvent = event
    }
    
    func loaderHide() {
        DispatchQueue.main.async { [self] in
            if let controller = topMostController() {
                controller.view.isUserInteractionEnabled = true
                spinner.removeFromSuperview()
                progressView.removeFromSuperview()
            }
        }
    }
    
    private func topMostController() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindowInConnectedScenes, let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        if let navController = topController as? UINavigationController {
            topController = navController.viewControllers.last!
        }
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        return topController
    }
    
    private func getDeviceName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    @objc public func cgUserNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if CustomerGlu.sdk_disable! == true {
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
    
    @objc public func setCrashLoggingEnabled(isCrashLoggingEnabled: Bool){
        CustomerGlu.isCrashLogsEnabled = isCrashLoggingEnabled
    }
    
    @objc public func setMetricsLoggingEnabled(isMetricsLoggingEnabled: Bool){
        CustomerGlu.isMetricsEnabled = isMetricsLoggingEnabled
    }
    
    @objc public func setDiagnosticsEnabled(isDiagnosticsEnabled: Bool){
        CustomerGlu.isDiagnosticsEnabled = isDiagnosticsEnabled
    }
    
    @objc public func setOpenWalletAsFallback(_ flag: Bool) {
        allowOpenWallet = flag
    }
    
    func setCampaignsModel(_ model: CGCampaignsModel?) {
        loadCampaignResponse = model
    }
    
    @objc internal func checkToOpenWalletOrNot(withCampaignID campaignID: String) -> Bool {
        // Check the user has set flag 'allowOpenWallet' false and based on that check is campaign ID valid is false
        if !allowOpenWallet,
           let loadCampaignResponse,
           let campaigns = loadCampaignResponse.campaigns,
           campaigns.count > 0,
            !OtherUtils.shared.validateCampaign(withCampaignID: campaignID, in: campaigns)
        {
            var eventInfo = [String: Any]()
            eventInfo["campaignId"] = campaignID
            eventInfo[APIParameterKey.messagekey] = "Invalid campaignId"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CG_INVALID_CAMPAIGN_ID").rawValue), object: nil, userInfo: eventInfo)
            return false
        }
        
        return true
    }
    
    @objc public func cgapplication(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], backgroundAlpha: Double = 0.5,auto_close_webview : Bool = CustomerGlu.auto_close_webview!, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            CustomerGlu.getInstance.printlog(cglog: "", isException: false, methodName: "CustomerGlu-cgapplication", posttoserver: true)
            return
        }
        if let messageID = userInfo[gcmMessageIDKey] {
            if(true == CustomerGlu.isDebugingEnabled){
                print("Message ID: \(messageID)")
            }
        }
        
        if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            let nudge_url = userInfo[NotificationsKey.nudge_url]
            if(true == CustomerGlu.isDebugingEnabled){
                print(nudge_url as Any)
            }
            let page_type = userInfo[NotificationsKey.page_type]
            let absoluteHeight = userInfo[NotificationsKey.absoluteHeight]
            let relativeHeight = userInfo[NotificationsKey.relativeHeight]
            let closeOnDeepLink = userInfo[NotificationsKey.closeOnDeepLink]
            
            let nudgeConfiguration  = CGNudgeConfiguration()
            if(page_type != nil){
                nudgeConfiguration.layout = page_type as! String
            }
            if(absoluteHeight != nil){
                nudgeConfiguration.absoluteHeight = Double(absoluteHeight as! String) ?? 0.0
            }
            if(relativeHeight != nil){
                nudgeConfiguration.relativeHeight = Double(relativeHeight as! String) ?? 0.0
            }
            if(closeOnDeepLink != nil){
                nudgeConfiguration.closeOnDeepLink = Bool(closeOnDeepLink as! String) ?? CustomerGlu.auto_close_webview!
            }
            
            if userInfo[NotificationsKey.glu_message_type] as? String == NotificationsKey.in_app {
                
                if(true == CustomerGlu.isDebugingEnabled){
                    print(page_type as Any)
                }
                if page_type as? String == CGConstants.BOTTOM_SHEET_NOTIFICATION {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: CGConstants.BOTTOM_SHEET_NOTIFICATION, backgroundAlpha: backgroundAlpha,auto_close_webview: auto_close_webview, nudgeConfiguration: nudgeConfiguration)
                    
                } else if ((page_type as? String == CGConstants.BOTTOM_DEFAULT_NOTIFICATION) || (page_type as? String == CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP)) {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: CGConstants.BOTTOM_DEFAULT_NOTIFICATION, backgroundAlpha: backgroundAlpha,auto_close_webview: auto_close_webview, nudgeConfiguration: nudgeConfiguration)
                } else if ((page_type as? String == CGConstants.MIDDLE_NOTIFICATIONS) || (page_type as? String == CGConstants.MIDDLE_NOTIFICATIONS_POPUP)) {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: CGConstants.MIDDLE_NOTIFICATIONS, backgroundAlpha: backgroundAlpha,auto_close_webview: auto_close_webview, nudgeConfiguration: nudgeConfiguration)
                } else {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: CGConstants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: backgroundAlpha,auto_close_webview: auto_close_webview, nudgeConfiguration: nudgeConfiguration)
                }
                
                self.postAnalyticsEventForNotification(userInfo: userInfo as! [String:AnyHashable])
                
            } else {
                
                return
            }
        } else {
        }
    }
    
    @objc public func presentToCustomerWebViewController(nudge_url: String, page_type: String, backgroundAlpha: Double, auto_close_webview : Bool, nudgeConfiguration : CGNudgeConfiguration? = nil) {
        
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.urlStr = nudge_url
        customerWebViewVC.auto_close_webview = auto_close_webview
        customerWebViewVC.notificationHandler = true
        customerWebViewVC.alpha = backgroundAlpha
        customerWebViewVC.nudgeConfiguration = nudgeConfiguration
        
        guard let topController = UIViewController.topViewController() else {
            return
        }
        
        if page_type == CGConstants.BOTTOM_SHEET_NOTIFICATION {
            customerWebViewVC.isbottomsheet = true
#if compiler(>=5.5)
            if #available(iOS 15.0, *) {
                if let sheet = customerWebViewVC.sheetPresentationController {
                    sheet.detents = [ .medium(), .large() ]
                }else{
                    customerWebViewVC.modalPresentationStyle = .pageSheet
                }
            } else {
                customerWebViewVC.modalPresentationStyle = .pageSheet
            }
#else
            customerWebViewVC.modalPresentationStyle = .pageSheet
#endif
        } else if ((page_type == CGConstants.BOTTOM_DEFAULT_NOTIFICATION) || (page_type == CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP)) {
            customerWebViewVC.isbottomdefault = true
            customerWebViewVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customerWebViewVC.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        } else if ((page_type == CGConstants.MIDDLE_NOTIFICATIONS) || (page_type == CGConstants.MIDDLE_NOTIFICATIONS_POPUP)) {
            customerWebViewVC.ismiddle = true
            customerWebViewVC.modalPresentationStyle = .overCurrentContext
        } else {
            customerWebViewVC.modalPresentationStyle = .overCurrentContext//.fullScreen
        }
        topController.present(customerWebViewVC, animated: true, completion: {
            self.hideFloatingButtons()
        })
    }
    
    @objc public func setDelaySeconds(delaySeconds: Double) {
        self.delaySeconds = delaySeconds
    }
    
    @objc public func displayBackgroundNotification(remoteMessage: [String: AnyHashable],auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        if CustomerGlu.sdk_disable! == true {
            CustomerGlu.getInstance.printlog(cglog: "", isException: false, methodName: "CustomerGlu-displayBackgroundNotification", posttoserver: false)
            return
        }
        
        if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: remoteMessage ) {
            let nudge_url = remoteMessage[NotificationsKey.nudge_url]
            if(true == CustomerGlu.isDebugingEnabled){
                print(nudge_url as Any)
            }
            let page_type = remoteMessage[NotificationsKey.page_type]
            
            let absoluteHeight = remoteMessage[NotificationsKey.absoluteHeight]
            let relativeHeight = remoteMessage[NotificationsKey.relativeHeight]
            let closeOnDeepLink = remoteMessage[NotificationsKey.closeOnDeepLink]
            
            let nudgeConfiguration  = CGNudgeConfiguration()
            if(page_type != nil){
                nudgeConfiguration.layout = page_type as! String
            }
            if(absoluteHeight != nil){
                nudgeConfiguration.absoluteHeight = Double(absoluteHeight as! String) ?? 0.0
            }
            if(relativeHeight != nil){
                nudgeConfiguration.relativeHeight = Double(relativeHeight as! String) ?? 0.0
            }
            if(closeOnDeepLink != nil){
                nudgeConfiguration.closeOnDeepLink = Bool(closeOnDeepLink as! String) ?? CustomerGlu.auto_close_webview!
            }
            
            if(true == CustomerGlu.isDebugingEnabled){
                print(page_type as Any)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [self] in
                if page_type as? String == CGConstants.BOTTOM_SHEET_NOTIFICATION {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: CGConstants.BOTTOM_SHEET_NOTIFICATION, backgroundAlpha: 0.5,auto_close_webview: auto_close_webview, nudgeConfiguration: nudgeConfiguration)
                } else if ((page_type as? String == CGConstants.BOTTOM_DEFAULT_NOTIFICATION) || (page_type as? String == CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP)) {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: CGConstants.BOTTOM_DEFAULT_NOTIFICATION, backgroundAlpha: 0.5,auto_close_webview: auto_close_webview, nudgeConfiguration: nudgeConfiguration)
                } else if((page_type as? String == CGConstants.MIDDLE_NOTIFICATIONS) || (page_type as? String == CGConstants.MIDDLE_NOTIFICATIONS_POPUP)) {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: CGConstants.MIDDLE_NOTIFICATIONS, backgroundAlpha: 0.5,auto_close_webview: auto_close_webview, nudgeConfiguration: nudgeConfiguration)
                } else {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: CGConstants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: 0.5,auto_close_webview: auto_close_webview, nudgeConfiguration: nudgeConfiguration)
                }
            }
            
            self.postAnalyticsEventForNotification(userInfo: remoteMessage)
        } else {
        }
    }
    
    @objc public func notificationFromCustomerGlu(remoteMessage: [String: AnyHashable]) -> Bool {
        let strType = remoteMessage[NotificationsKey.type] as? String
        if strType == NotificationsKey.CustomerGlu {
            return true
        } else {
            return false
        }
    }
    
    @objc public func clearGluData() {
        // So that SDK can be iniatilised again
        sdkInitialized = false
        
        var eventData: [String: Any] = [:]
        
        // Needs to be deleted. Just for reference.
        let writekey = CustomerGlu.sdkWriteKey
        if !(writekey.isEmpty){
            eventData["writeKeyPresent"] = "true"

        }else {
            eventData["writeKeyPresent"] = "false"
        }
        if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil {

        eventData["userRegistered"] = "true"
        }else{
            eventData["userRegistered"] = "false"

        }
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_CLEAR_GLU_DATA_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        dismissFloatingButtons(is_remove: true)
        self.arrFloatingButton.removeAll()
        popupDict.removeAll()
        CustomerGlu.entryPointdata.removeAll()
        entryPointPopUpModel = EntryPointPopUpModel()
        self.popupDisplayScreens.removeAll()
        
        userDefaults.removeObject(forKey: CGConstants.CUSTOMERGLU_TOKEN)
        userDefaults.removeObject(forKey: CGConstants.CUSTOMERGLU_USERID)
        userDefaults.removeObject(forKey: CGConstants.CUSTOMERGLU_ANONYMOUSID)
        userDefaults.removeObject(forKey: CGConstants.CustomerGluCrash)
        userDefaults.removeObject(forKey: CGConstants.CustomerGluPopupDict)
        userDefaults.removeObject(forKey: CGConstants.CUSTOMERGLU_USERDATA)
        userDefaults.removeObject(forKey: CGConstants.CUSTOMERGLU_LIGHT_LOTTIE_FILE_PATH)
        userDefaults.removeObject(forKey: CGConstants.CUSTOMERGLU_DARK_LOTTIE_FILE_PATH)
        userDefaults.removeObject(forKey: CGConstants.CUSTOMERGLU_LIGHT_EMBEDLOTTIE_FILE_PATH)
        userDefaults.removeObject(forKey: CGConstants.CUSTOMERGLU_DARK_EMBEDLOTTIE_FILE_PATH)
        CustomerGlu.getInstance.cgUserData = CGUser()
        ApplicationManager.appSessionId = UUID().uuidString
        CGSentryHelper.shared.logoutSentryUser()
        
        // Disconnect MQTT
        if let enableMqtt = self.appconfigdata?.enableMqtt, enableMqtt, CGMqttClientHelper.shared.checkIsMQTTConnected() {
            CGMqttClientHelper.shared.disconnectMQTT()
        }
    }
    
    // MARK: - API Calls Methods
    
    @objc public func initializeSdk() {
        if !sdkInitialized {
            // So SDK is initialized
            sdkInitialized = true
            
            //  ExampleEvents
            var eventData: [String: Any] = [:]
            
            // Needs to be deleted. Just for reference.
            let writekey = CustomerGlu.sdkWriteKey
            if !(writekey.isEmpty) {
                eventData["writeKeyPresent"] = "true"
            } else {
                eventData["writeKeyPresent"] = "false"
            }
            if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil {
                eventData["userRegistered"] = "true"
            } else {
                eventData["userRegistered"] = "false"
            }

            CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_INIT_START, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
           
            // Get Config
            self.getAppConfig { result in
            }
        }
    }
    
    @objc public func setWriteKey(_ writeKey: String) {
        CustomerGlu.sdkWriteKey = writeKey
    }
    
    @objc internal func getAppConfig(completion: @escaping (Bool) -> Void) {
        
        let eventInfo = [String: String]()
        
        
        APIManager.appConfig(queryParameters: eventInfo as NSDictionary) { result in
            switch result {
            case .success(let response):
                if (response.data != nil && response.data?.mobile != nil) {
                    self.appconfigdata = (response.data?.mobile)!
                    self.updatedAllConfigParam()
                }
                completion(true)
                
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-getAppConfig", posttoserver: true)
                completion(false)
            }
        }
        
        
    }
    func updatedAllConfigParam() -> Void{
        if(self.appconfigdata != nil) {
            if(self.appconfigdata!.disableSdk != nil){
                CustomerGlu.getInstance.disableGluSdk(disable: (self.appconfigdata!.disableSdk ?? CustomerGlu.sdk_disable)!)
            }
            
            if self.appconfigdata!.isCrashLoggingEnabled != nil {
                CustomerGlu.getInstance.setCrashLoggingEnabled(isCrashLoggingEnabled: (self.appconfigdata?.isCrashLoggingEnabled ?? CustomerGlu.isCrashLogsEnabled)!)
            }
            
            if self.appconfigdata?.isDiagnosticsEnabled != nil {
                CustomerGlu.getInstance.setDiagnosticsEnabled(isDiagnosticsEnabled: (self.appconfigdata?.isDiagnosticsEnabled ?? CustomerGlu.isDiagnosticsEnabled)!)
            }
            
            if self.appconfigdata?.isMetricsEnabled != nil {
                CustomerGlu.getInstance.setMetricsLoggingEnabled(isMetricsLoggingEnabled: (self.appconfigdata?.isMetricsEnabled ?? CustomerGlu.isMetricsEnabled)!)
            }
            
            if(self.appconfigdata!.enableAnalytics != nil){
                CustomerGlu.getInstance.enableAnalyticsEvent(event: (self.appconfigdata!.enableAnalytics ?? CustomerGlu.analyticsEvent)!)
            }
            
            if let appconfigdata = self.appconfigdata, let sentrySecretData = appconfigdata.sentryDsn, let iOSSentryKey = sentrySecretData.iOS {
                CustomerGlu.sentryDSN = iOSSentryKey
            }
            
            if self.appconfigdata!.enableSentry != nil  {
                CustomerGlu.sentry_enable =  self.appconfigdata?.enableSentry ?? false
                CGSentryHelper.shared.setupSentry()
            }
            
            if let enableMqtt = self.appconfigdata?.enableMqtt, enableMqtt {
                var eventData: [String: Any] = [:]
                eventData["enableMqtt"] = enableMqtt
                
                CGEventsDiagnosticsHelper.shared.sendMultipleDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_MQTT_ENABLED, eventTypes: [CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, CGDiagnosticConstants.CG_TYPE_METRICS], eventMeta:eventData)
                
                // Initialize Mqtt
                if CGMqttClientHelper.shared.checkIsMQTTConnected() {
                    CGMqttClientHelper.shared.disconnectMQTT()
                }
                initializeMqtt()
            } else {
                var eventData: [String: Any] = [:]
                eventData["enableMqtt"] = false
                CGEventsDiagnosticsHelper.shared.sendMultipleDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_MQTT_DISABLED, eventTypes: [CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, CGDiagnosticConstants.CG_TYPE_METRICS], eventMeta:eventData)
            }
            
            if(self.appconfigdata!.enableEntryPoints != nil){
                CustomerGlu.getInstance.enableEntryPoints(enabled: self.appconfigdata!.enableEntryPoints ?? CustomerGlu.isEntryPointEnabled)
            }
            
            if self.appconfigdata!.enableDarkMode != nil {
                CustomerGlu.getInstance.enableDarkMode(isDarkModeEnabled: (self.appconfigdata!.enableDarkMode ?? CustomerGlu.enableDarkMode)!)
            }
            
            if self.appconfigdata!.listenToSystemDarkLightMode != nil {
                CustomerGlu.getInstance.listenToDarkMode(allowToListenDarkMode: (self.appconfigdata!.listenToSystemDarkLightMode ?? CustomerGlu.listenToSystemDarkMode)!)
            }
            
            if(self.appconfigdata!.errorCodeForDomain != nil && self.appconfigdata!.errorMessageForDomain != nil){
                CustomerGlu.getInstance.configureDomainCodeMsg(code: self.appconfigdata!.errorCodeForDomain ?? CustomerGlu.doamincode , message: self.appconfigdata!.errorMessageForDomain ?? CustomerGlu.textMsg)
            }
            
            if(self.appconfigdata!.iosSafeArea != nil){
                
                CustomerGlu.getInstance.configureSafeArea(topHeight: Int(self.appconfigdata!.iosSafeArea?.newTopHeight ?? CustomerGlu.topSafeAreaHeight), bottomHeight: Int(self.appconfigdata!.iosSafeArea?.newBottomHeight ?? CustomerGlu.bottomSafeAreaHeight), topSafeAreaLightColor: UIColor(hex: self.appconfigdata!.iosSafeArea?.lightTopColor ?? CustomerGlu.topSafeAreaColor.hexString) ?? CustomerGlu.topSafeAreaColor, bottomSafeAreaLightColor: UIColor(hex: self.appconfigdata!.iosSafeArea?.lightBottomColor ?? CustomerGlu.bottomSafeAreaColor.hexString) ?? CustomerGlu.bottomSafeAreaColor, topSafeAreaDarkColor:  UIColor(hex: self.appconfigdata!.iosSafeArea?.darkTopColor ?? CustomerGlu.topSafeAreaColor.hexString) ?? CustomerGlu.topSafeAreaColor, bottomSafeAreaDarkColor: UIColor(hex: self.appconfigdata!.iosSafeArea?.darkBottomColor ?? CustomerGlu.bottomSafeAreaColor.hexString) ?? CustomerGlu.bottomSafeAreaColor)
                
                
            }
            
            if(self.appconfigdata!.loadScreenColor != nil){
                CustomerGlu.getInstance.configureLoadingScreenColor(color: UIColor(hex: self.appconfigdata!.loadScreenColor ?? CustomerGlu.defaultBGCollor.hexString) ?? CustomerGlu.defaultBGCollor)
                
            }
            
            if(self.appconfigdata!.lightBackground != nil){
                CustomerGlu.getInstance.configureLightBackgroundColor(color: UIColor(hex: self.appconfigdata!.lightBackground ?? CustomerGlu.lightBackground.hexString) ?? CustomerGlu.lightBackground)
            }
            
            if(self.appconfigdata!.darkBackground != nil){
                CustomerGlu.getInstance.configureDarkBackgroundColor(color: UIColor(hex: self.appconfigdata!.darkBackground ?? CustomerGlu.darkBackground.hexString) ?? CustomerGlu.darkBackground)
            }
            
            if(self.appconfigdata!.loaderColor != nil){
                CustomerGlu.getInstance.configureLoaderColour(color: [UIColor(hex: self.appconfigdata!.loaderColor ?? CustomerGlu.arrColor[0].hexString) ?? CustomerGlu.arrColor[0]])
            }
            
            if(self.appconfigdata!.whiteListedDomains != nil){
                CustomerGlu.getInstance.configureWhiteListedDomains(domains: self.appconfigdata!.whiteListedDomains ?? CustomerGlu.whiteListedDomains)
            }
            
            if let loaderURLLight = self.appconfigdata?.loaderConfig?.loaderURL?.light {
                CustomerGlu.getInstance.configureLightLoaderURL(locallottieLoaderURL: loaderURLLight)
            }
            
            if let loaderURLDark = self.appconfigdata?.loaderConfig?.loaderURL?.dark {
                CustomerGlu.getInstance.configureDarkLoaderURL(locallottieLoaderURL: loaderURLDark)
            }
            
            if let embedLoaderURLLight = self.appconfigdata?.loaderConfig?.embedLoaderURL?.light {
                CustomerGlu.getInstance.configureLightEmbedLoaderURL(locallottieLoaderURL: embedLoaderURLLight)
            }
            
            if let embedLoaderURLDark = self.appconfigdata?.loaderConfig?.embedLoaderURL?.dark {
                CustomerGlu.getInstance.configureDarkEmbedLoaderURL(locallottieLoaderURL: embedLoaderURLDark)
            }
            
            if(self.appconfigdata!.activityIdList != nil && self.appconfigdata!.activityIdList?.ios != nil){
                CustomerGlu.getInstance.configScreens = self.appconfigdata!.activityIdList?.ios ?? []
            }
            if(self.appconfigdata!.testUserIds != nil ){
                CustomerGlu.testUsers = self.appconfigdata!.testUserIds ?? []
            }
            if(self.appconfigdata!.bannerIds != nil && self.appconfigdata!.bannerIds?.ios != nil){
                CustomerGlu.bannerIds = self.appconfigdata!.bannerIds?.ios ?? []
            }
            if(self.appconfigdata!.embedIds != nil && self.appconfigdata!.embedIds?.ios != nil){
                CustomerGlu.embedIds = self.appconfigdata!.embedIds?.ios ?? []
            }
            
            if let allowAnonymousRegistration = self.appconfigdata?.allowAnonymousRegistration {
                CustomerGlu.isAnonymousFlowAllowed = allowAnonymousRegistration
            }
        }
    }
    
    @objc public func registerDevice(userdata: [String: AnyHashable], completion: @escaping (Bool) -> Void) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || (userdata[APIParameterKey.userId] == nil && !allowAnonymousRegistration()){
            CustomerGlu.getInstance.printlog(cglog: "Fail to call registerDevice", isException: false, methodName: "CustomerGlu-registerDevice-1", posttoserver: true)
            CustomerGlu.bannersHeight = [String:Any]()
            CustomerGlu.embedsHeight = [String:Any]()
            completion(false)
            return
        }
        
        let userdata: [String: AnyHashable] = userdata.compactMapValues { $0 }
        
        // Generate the UDID only once and save it to user defaults for MQTT Identifier
        let mqttIdentifier = decryptUserDefaultKey(userdefaultKey: CGConstants.MQTT_Identifier)
        if mqttIdentifier.isEmpty {
            let udid = UUID().uuidString
            encryptUserDefaultKey(str: udid, userdefaultKey: CGConstants.MQTT_Identifier)
        }
        
        var eventData: [String: Any] = [:]
        eventData["registerObject"] = userdata
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_USER_REGISTRATION_START, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        var userData = userdata
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            if(true == CustomerGlu.isDebugingEnabled){
                print(uuid)
            }
            userData[APIParameterKey.deviceId] = uuid
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let writekey = CustomerGlu.sdkWriteKey
        userData[APIParameterKey.deviceType] = "ios"
        userData[APIParameterKey.deviceName] = getDeviceName()
        userData[APIParameterKey.appVersion] = appVersion
        userData[APIParameterKey.writeKey] = writekey
        
        if CustomerGlu.fcm_apn == "fcm" {
            userData[APIParameterKey.apnsDeviceToken] = ""
            userData[APIParameterKey.firebaseToken] = fcmToken
        } else {
            userData[APIParameterKey.firebaseToken] = ""
            userData[APIParameterKey.apnsDeviceToken] = apnToken
        }
        
        // Manage UserID & AnonymousId
        let t_userid = userData[APIParameterKey.userId] as? String ?? ""
        let t_anonymousIdP = userData[APIParameterKey.anonymousId] as? String ?? ""
        let t_anonymousIdS = self.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_ANONYMOUSID) as String? ?? ""

        if self.allowAnonymousRegistration() {
            if (t_userid.count <= 0) {
                // Pass only anonymousId and removed UserID
                if (t_anonymousIdP.count > 0) {
                    userData[APIParameterKey.anonymousId] = t_anonymousIdP
                    
                    // Remove old user stored data
                    if(t_anonymousIdS.count > 0 && t_anonymousIdS != t_anonymousIdP){
                        self.clearGluData()
                    }
                } else if (t_anonymousIdS.count > 0) {
                    userData[APIParameterKey.anonymousId] = t_anonymousIdS
                } else {
                    userData[APIParameterKey.anonymousId] = UUID().uuidString
                }
                userData.removeValue(forKey: APIParameterKey.userId)
            } else if (t_anonymousIdS.count > 0) {
                // Pass anonymousId and UserID Both
                userData[APIParameterKey.anonymousId] = t_anonymousIdS
            } else {
                // Pass only UserID and removed anonymousId
                userData.removeValue(forKey: APIParameterKey.anonymousId)
            }
        } else {
            // Pass only UserID and removed anonymousId
            userData.removeValue(forKey: APIParameterKey.anonymousId)
        }
        
        if userData[APIParameterKey.userId] == nil && userData[APIParameterKey.anonymousId] == nil {
            print("UserId is either null or Empty")
            completion(false)
            return
        }
        
        APIManager.userRegister(queryParameters: userData as NSDictionary) { result in
            switch result {
            case .success(let response):
                if response.success! {
                    // Setup Sentry user
                    CGSentryHelper.shared.setupUser(userId: response.data?.user?.userId ?? "", clientId: response.data?.user?.client ?? "")
                    self.encryptUserDefaultKey(str: response.data?.token ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN)
                    self.encryptUserDefaultKey(str: response.data?.user?.userId ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_USERID)
                    self.encryptUserDefaultKey(str: response.data?.user?.anonymousId ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_ANONYMOUSID)
                    
                    self.cgUserData = response.data?.user ?? CGUser()
                    var data: Data?
                    do {
                        data = try JSONEncoder().encode(self.cgUserData)
                    } catch(let error) {
                        CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "registerDevice", posttoserver: true)
                    }
                    guard let data = data, let jsonString = String(data: data, encoding: .utf8) else { return }
                    self.encryptUserDefaultKey(str: jsonString, userdefaultKey: CGConstants.CUSTOMERGLU_USERDATA)
                    self.userDefaults.synchronize()
                    
                    if let enableMqtt = self.appconfigdata?.enableMqtt, enableMqtt {
                        if CGMqttClientHelper.shared.checkIsMQTTConnected() {
                            CGMqttClientHelper.shared.disconnectMQTT()
                        }
                        self.initializeMqtt()
                    }
                    
                    ApplicationManager.openWalletApi { success, response in
                        if success {
                            if CustomerGlu.isEntryPointEnabled {
                                CustomerGlu.bannersHeight = nil
                                CustomerGlu.embedsHeight = nil
                                APIManager.getEntryPointdata(queryParameters: ["consumer": "MOBILE"]) { result in
                                    switch result {
                                    case .success(let responseGetEntry):
                                        DispatchQueue.main.async {
                                            self.dismissFloatingButtons(is_remove: false)
                                        }
                                        CustomerGlu.entryPointdata.removeAll()
                                        CustomerGlu.entryPointdata = responseGetEntry.data
                                        
                                        // FLOATING Buttons
                                        let floatingButtons = CustomerGlu.entryPointdata.filter {
                                            $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP"
                                        }
                                        
                                        self.entryPointInfoAddDelete(entryPoint: floatingButtons)
                                        self.addFloatingBtns()
                                        self.postBannersCount()
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("EntryPointLoaded").rawValue), object: nil, userInfo: nil)
                                        completion(true)
                                        
                                    case .failure(let error):
                                        CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-registerDevice-2", posttoserver: true)
                                        CustomerGlu.bannersHeight = [String:Any]()
                                        CustomerGlu.embedsHeight = [String:Any]()
                                        completion(true)
                                    }
                                }
                            } else {
                                CustomerGlu.bannersHeight = [String:Any]()
                                CustomerGlu.embedsHeight = [String:Any]()
                                completion(true)
                            }
                        } else {
                            CustomerGlu.bannersHeight = [String:Any]()
                            CustomerGlu.embedsHeight = [String:Any]()
                            completion(true)
                        }
                    }
                } else {
                    CustomerGlu.getInstance.printlog(cglog: "", isException: false, methodName: "CustomerGlu-registerDevice-3", posttoserver: true)
                    CustomerGlu.bannersHeight = [String:Any]()
                    CustomerGlu.embedsHeight = [String:Any]()
                    completion(false)
                }
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-registerDevice-4", posttoserver: true)
                CustomerGlu.bannersHeight = [String:Any]()
                CustomerGlu.embedsHeight = [String:Any]()
                completion(false)
            }
        }
        eventData = [:]
        eventData["registerObject"] = userdata
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_USER_REGISTRATION_END, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
    }
    
    @objc public func updateProfile(userdata: [String: AnyHashable], completion: @escaping (Bool) -> Void) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call updateProfile", isException: false, methodName: "CustomerGlu-updateProfile-1", posttoserver: true)
            CustomerGlu.bannersHeight = [String:Any]()
            CustomerGlu.embedsHeight = [String:Any]()
            completion(false)
            return
        }
        
        var userData = userdata
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            if(true == CustomerGlu.isDebugingEnabled){
                print(uuid)
            }
            userData[APIParameterKey.deviceId] = uuid
        }
        let user_id = decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID)
        if user_id.count < 0 {
            CustomerGlu.getInstance.printlog(cglog: "user_id is nil", isException: false, methodName: "CustomerGlu-updateProfile-2", posttoserver: true)
            return
        }
        //user_id.count will always be > 0
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let writekey = CustomerGlu.sdkWriteKey
        userData[APIParameterKey.deviceType] = "ios"
        userData[APIParameterKey.deviceName] = getDeviceName()
        userData[APIParameterKey.appVersion] = appVersion
        userData[APIParameterKey.writeKey] = writekey
        userData[APIParameterKey.userId] = user_id
        
        if CustomerGlu.fcm_apn == "fcm" {
            userData[APIParameterKey.apnsDeviceToken] = ""
            userData[APIParameterKey.firebaseToken] = fcmToken
        } else {
            userData[APIParameterKey.firebaseToken] = ""
            userData[APIParameterKey.apnsDeviceToken] = apnToken
        }
        
        // Manage UserID & AnonymousId
        let t_anonymousIdS = self.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_ANONYMOUSID) as String? ?? ""
        if (t_anonymousIdS.count > 0){
            // Pass anonymousId and UserID Both
            userData[APIParameterKey.anonymousId] = t_anonymousIdS
        }else{
            // Pass only UserID and removed anonymousId
            userData.removeValue(forKey: APIParameterKey.anonymousId)
        }
        
        APIManager.userRegister(queryParameters: userData as NSDictionary) { result in
            switch result {
            case .success(let response):
                if response.success! {
                    self.encryptUserDefaultKey(str: response.data?.token ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN)
                    self.encryptUserDefaultKey(str: response.data?.user?.userId ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_USERID)
                    self.encryptUserDefaultKey(str: response.data?.user?.anonymousId ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_ANONYMOUSID)
                    
                    self.cgUserData = response.data?.user ?? CGUser()
                    var data: Data?
                    do {
                        data = try JSONEncoder().encode(self.cgUserData)
                    } catch(let error) {
                        CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "updateProfile", posttoserver: true)
                    }
                    
                    guard let data = data, let jsonString = String(data: data, encoding: .utf8) else { return }
                    self.encryptUserDefaultKey(str: jsonString, userdefaultKey: CGConstants.CUSTOMERGLU_USERDATA)
                    
                    self.userDefaults.synchronize()
                    
                    if CustomerGlu.isEntryPointEnabled {
                        CustomerGlu.bannersHeight = nil
                        CustomerGlu.embedsHeight = nil
                        APIManager.getEntryPointdata(queryParameters: ["consumer": "MOBILE"]) { result in
                            switch result {
                            case .success(let responseGetEntry):
                                DispatchQueue.main.async {
                                    self.dismissFloatingButtons(is_remove: false)
                                }
                                CustomerGlu.entryPointdata.removeAll()
                                CustomerGlu.entryPointdata = responseGetEntry.data
                                
                                // FLOATING Buttons
                                let floatingButtons = CustomerGlu.entryPointdata.filter {
                                    $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP"
                                }
                                
                                self.entryPointInfoAddDelete(entryPoint: floatingButtons)
                                self.addFloatingBtns()
                                self.postBannersCount()
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("EntryPointLoaded").rawValue), object: nil, userInfo: nil)
                                completion(true)
                                
                            case .failure(let error):
                                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-updateProfile-3", posttoserver: true)
                                CustomerGlu.bannersHeight = [String:Any]()
                                CustomerGlu.embedsHeight = [String:Any]()
                                completion(true)
                            }
                        }
                    } else {
                        CustomerGlu.bannersHeight = [String:Any]()
                        CustomerGlu.embedsHeight = [String:Any]()
                        completion(true)
                    }
                } else {
                    CustomerGlu.getInstance.printlog(cglog: "", isException: false, methodName: "CustomerGlu-updateProfile-4", posttoserver: true)
                    CustomerGlu.bannersHeight = [String:Any]()
                    CustomerGlu.embedsHeight = [String:Any]()
                    completion(false)
                }
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-updateProfile-5", posttoserver: true)
                CustomerGlu.bannersHeight = [String:Any]()
                CustomerGlu.embedsHeight = [String:Any]()
                completion(false)
            }
        }
    }
    
    
    /***
        Update Banner Id list
     */
    public func addBannerId(bannerId : String){
        if !CustomerGlu.bannerIds.contains(bannerId){
            CustomerGlu.bannerIds.append(bannerId)
        }
    }
    
    
    /***
        Update Embed Id list
     */
    public func addEmbedId(embedId : String){
        if !CustomerGlu.embedIds.contains(embedId){
            CustomerGlu.embedIds.append(embedId)
        }
    }

    private func getEntryPointData() {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call getEntryPointData", isException: false, methodName: "CustomerGlu-getEntryPointData", posttoserver: true)
            CustomerGlu.bannersHeight = [String:Any]()
            CustomerGlu.embedsHeight = [String:Any]()
            return
        }
        var eventData: [String: Any] = [:]
        var token: String? = ""
        if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil {
            token = self.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN)
            eventData["token"] = token
        }else{
            eventData["token"] = token

        }
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_GET_ENTRY_POINT_START, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        CustomerGlu.bannersHeight = nil
        CustomerGlu.embedsHeight = nil
        
        let queryParameters: [AnyHashable: Any] = ["consumer": "MOBILE"]
        
        APIManager.getEntryPointdata(queryParameters: queryParameters as NSDictionary) { [self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.dismissFloatingButtons(is_remove: false)
                }
                
                // Normal Flow
                CustomerGlu.entryPointdata.removeAll()
                CustomerGlu.entryPointdata = response.data
                
                // FLOATING Buttons
                let floatingButtons = CustomerGlu.entryPointdata.filter {
                    $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP"
                }
                
                entryPointInfoAddDelete(entryPoint: floatingButtons)
                addFloatingBtns()
                postBannersCount()
                
                /*
                 Below code only handles that scenario to show POPUP if it exists in API response.
                 */
                let popupData = CustomerGlu.entryPointdata.filter {
                    $0.mobile.container.type == "POPUP"
                }
                if popupData.count > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                        CustomerGlu.getInstance.setCurrentClassName(className: CustomerGlu.getInstance.activescreenname)
                    })
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("EntryPointLoaded").rawValue), object:    nil, userInfo: nil)

            case .failure(let error):
                CustomerGlu.bannersHeight = [String:Any]()
                CustomerGlu.embedsHeight = [String:Any]()
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-getEntryPointData", posttoserver: true)
            }
        }
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_GET_ENTRY_POINT_START, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
    }
    
    private func entryPointInfoAddDelete(entryPoint: [CGData]) {
        
        if entryPoint.count > 0 {
            
            let jsonString = decryptUserDefaultKey(userdefaultKey: CGConstants.CustomerGluPopupDict)
            let jsonData = Data(jsonString.utf8)
            let decoder = JSONDecoder()
            do {
                if(jsonData.count > 0){
                    let popupItems = try decoder.decode(EntryPointPopUpModel.self, from: jsonData)
                    popupDict = popupItems.popups!
                }
            } catch {
                print(error.localizedDescription)
            }
            
            for dict in entryPoint {
                if popupDict.contains(where: { $0._id == dict._id }) {
                    
                    if let index = popupDict.firstIndex(where: {$0._id == dict._id}) {
                        
                        var refreshlocal : Bool = false
                        if(dict.mobile.conditions.showCount.dailyRefresh == true && popupDict[index].showcount?.dailyRefresh == true){
                            
                            if !(Calendar.current.isDate(popupDict[index].popupdate ?? Date(), equalTo: Date(), toGranularity: .day)){
                                refreshlocal = true
                            }
                            
                        }else if(dict.mobile.conditions.showCount.dailyRefresh != popupDict[index].showcount?.dailyRefresh){
                            refreshlocal = true
                        }
                        
                        if (true == refreshlocal){
                            popupDict[index]._id = dict._id
                            popupDict[index].showcount = dict.mobile.conditions.showCount
                            popupDict[index].showcount?.count = 0
                            popupDict[index].delay = dict.mobile.conditions.delay
                            popupDict[index].backgroundopacity = dict.mobile.conditions.backgroundOpacity
                            popupDict[index].priority = dict.mobile.conditions.priority
                            popupDict[index].popupdate = Date()
                            popupDict[index].type = dict.mobile.container.type
                        }
                    }
                    
                } else {
                    var popupInfo = PopUpModel()
                    popupInfo._id = dict._id
                    popupInfo.showcount = dict.mobile.conditions.showCount
                    popupInfo.showcount?.count = 0
                    popupInfo.delay = dict.mobile.conditions.delay
                    popupInfo.backgroundopacity = dict.mobile.conditions.backgroundOpacity
                    popupInfo.priority = dict.mobile.conditions.priority
                    popupInfo.popupdate = Date()
                    popupInfo.type = dict.mobile.container.type
                    popupDict.append(popupInfo)
                }
            }
            
            for item in popupDict {
                if entryPoint.contains(where: { $0._id == item._id }) {
                    
                } else {
                    // remove item from popupDict
                    if let index = popupDict.firstIndex(where: {$0._id == item._id}) {
                        popupDict.remove(at: index)
                    }
                }
            }
            
            entryPointPopUpModel.popups = popupDict
            
            var data: Data?
            
            do {
                data = try JSONEncoder().encode(entryPointPopUpModel)
            } catch(let error) {
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "entryPointInfoAddDelete", posttoserver: true)
            }
            
            guard let data = data, let jsonString2 = String(data: data, encoding: .utf8) else { return }
            encryptUserDefaultKey(str: jsonString2, userdefaultKey: CGConstants.CustomerGluPopupDict)
        }
    }
    
    @objc public func openWalletWithURL(nudgeConfiguration: CGNudgeConfiguration) {
        CustomerGlu.getInstance.presentToCustomerWebViewController(nudge_url: nudgeConfiguration.url, page_type: nudgeConfiguration.layout, backgroundAlpha: nudgeConfiguration.opacity,auto_close_webview: nudgeConfiguration.closeOnDeepLink)
    }
    
    @objc public func openWalletWithURL(url: String, auto_close_webview : Bool = CustomerGlu.auto_close_webview ?? false) {
        CustomerGlu.getInstance.presentToCustomerWebViewController(nudge_url: url, page_type: CGConstants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: 0.5,auto_close_webview: auto_close_webview)
    }
    
    @objc public func openURLWithNudgeConfig(url: String, nudgeConfiguration: CGNudgeConfiguration){
        CustomerGlu.getInstance.presentToCustomerWebViewController(nudge_url: url, page_type: nudgeConfiguration.layout, backgroundAlpha: nudgeConfiguration.opacity, auto_close_webview: nudgeConfiguration.closeOnDeepLink)
    }
    
    internal func openNudgeWithValidToken(nudgeId: String, layout: String = CGConstants.FULL_SCREEN_NOTIFICATION, bg_opacity: Double = 0.5, closeOnDeeplink : Bool = true, nudgeConfiguration : CGNudgeConfiguration? = nil) {
        if(nudgeId.count > 0 && CustomerGlu.sdk_disable == false){
            APIManager.getWalletRewards(queryParameters: [:]) { result in
                switch result {
                case .success(let response):
                    // Save this - To open / not open wallet incase of failure / invalid campaignId in loadCampaignById
                    self.setCampaignsModel(response)
                    
                    if(response.defaultUrl.count > 0){
                        let url = URL(string: response.defaultUrl)
                        if(url != nil){
                            let scheme = url?.scheme
                            let host = url?.host
                            let userid = CustomerGlu.getInstance.cgUserData.userId
                            let writekey = CustomerGlu.sdkWriteKey
                            
                            var layout = layout
                            if let nudgeConfiguration = nudgeConfiguration {
                                layout = nudgeConfiguration.layout
                            }
                            var cglayout = CGConstants.FULL_SCREEN_NOTIFICATION
                            if(layout == "middle-popup"){
                                cglayout = CGConstants.MIDDLE_NOTIFICATIONS
                            }else if(layout == "bottom-popup"){
                                cglayout = CGConstants.BOTTOM_DEFAULT_NOTIFICATION
                            }else if(layout == "bottom-slider"){
                                cglayout = CGConstants.BOTTOM_SHEET_NOTIFICATION
                            }
                            
                            var finalurl = scheme
                            finalurl! += "://"
                            finalurl! += host!
                            finalurl! += "/fragment-map/?"
                            finalurl! += "fragmentMapId=\(nudgeId)"
                            finalurl! += "&userId=\(userid ?? "")"
                            finalurl! += "&writeKey=\(writekey ?? "")"
                            
                            DispatchQueue.main.async {
                                if(nudgeConfiguration != nil){
                                    CustomerGlu.getInstance.presentToCustomerWebViewController(nudge_url: finalurl!, page_type: nudgeConfiguration!.layout, backgroundAlpha: nudgeConfiguration!.opacity,auto_close_webview: nudgeConfiguration!.closeOnDeepLink, nudgeConfiguration: nudgeConfiguration)
                                    
                                }else{
                                    CustomerGlu.getInstance.presentToCustomerWebViewController(nudge_url: finalurl!, page_type: cglayout, backgroundAlpha: bg_opacity,auto_close_webview: closeOnDeeplink)
                                }
                            }
                        }else{
                            CustomerGlu.getInstance.printlog(cglog: "defaultUrl is not valid", isException: false, methodName: "openNudge-getWalletRewards", posttoserver: true)
                        }
                        
                    }else{
                        CustomerGlu.getInstance.printlog(cglog: "defaultUrl not found", isException: false, methodName: "openNudge-getWalletRewards", posttoserver: true)
                    }
                    
                    break
                    
                case .failure(let error):
                    CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "openNudge-getWalletRewards", posttoserver: true)
                }
            }
        }else{
            CustomerGlu.getInstance.printlog(cglog: "nudgeId / layout is not found OR SDK is disable", isException: false, methodName: "openNudge-getWalletRewards", posttoserver: true)
        }
    }
    @objc public func openNudge(nudgeId: String, nudgeConfiguration: CGNudgeConfiguration? = nil, layout: String = "full-default", bg_opacity: Double = 0.5, closeOnDeeplink : Bool = CustomerGlu.auto_close_webview!) {
        
        var eventData: [String: Any] = [:]
        eventData["nudgeId"] = nudgeId
        eventData["nudgeConfiguration"] = nudgeConfiguration
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_OPEN_NUDGE_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        if ApplicationManager.doValidateToken() == true {
            openNudgeWithValidToken(nudgeId: nudgeId, layout: layout, bg_opacity: bg_opacity, closeOnDeeplink: closeOnDeeplink,nudgeConfiguration: nudgeConfiguration)
        } else {
            let userData = [String: AnyHashable]()
            CustomerGlu.getInstance.updateProfile(userdata: userData) { success in
                if success {
                    self.openNudgeWithValidToken(nudgeId: nudgeId, layout: layout, bg_opacity: bg_opacity, closeOnDeeplink: closeOnDeeplink,nudgeConfiguration: nudgeConfiguration)
                } else {
                    CustomerGlu.getInstance.printlog(cglog: "UpdateProfile API fail", isException: false, methodName: "openNudge-updateProfile", posttoserver: true)
                }
            }
        }
    }
    
    @objc private func excecuteDeepLink(firstpath:String, cgdeeplink:CGDeeplinkData, completion: @escaping (CGSTATE, String, CGDeeplinkData? ) -> Void){
        
        let nudgeConfiguration = CGNudgeConfiguration()
        nudgeConfiguration.closeOnDeepLink = cgdeeplink.content!.closeOnDeepLink!
        nudgeConfiguration.relativeHeight = cgdeeplink.container?.relativeHeight ?? 0.0
        nudgeConfiguration.absoluteHeight = cgdeeplink.container?.absoluteHeight ?? 0.0
        nudgeConfiguration.layout = cgdeeplink.container?.type ?? ""
        
        CustomerGlu.getInstance.loaderShow(withcoordinate: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        ApplicationManager.loadAllCampaignsApi(type: "", value: "", loadByparams: [:]) { success, campaignsModel in
            CustomerGlu.getInstance.loaderHide()
            if success {
                // Save this - To open / not open wallet incase of failure / invalid campaignId in loadCampaignById
                self.setCampaignsModel(campaignsModel)

                let defaultwalleturl = String(campaignsModel?.defaultUrl ?? "")
                var cgstate = CGSTATE.EXCEPTION
                if(firstpath == "u"){
                    completion(CGSTATE.DEEPLINK_URL, "", cgdeeplink)
                    return
                }
                else if(firstpath == "c"){
                    let local_id = firstpath == "c" ? (cgdeeplink.content?.campaignId ?? "") : (cgdeeplink.content?.url ?? "")
                    if local_id.count == 0 {
                        // load wallet defaultwalleturl
                        nudgeConfiguration.url = defaultwalleturl
                        cgstate = firstpath == "c" ? CGSTATE.INVALID_CAMPAIGN : CGSTATE.INVALID_URL
                        
                    } else if local_id.contains("http://") || local_id.contains("https://") {
                        // Load url local_id
                        nudgeConfiguration.url = local_id
                        if (local_id.count > 0 && (URL(string: local_id) != nil)){
                            cgstate = CGSTATE.SUCCESS
                        }else{
                            cgstate = CGSTATE.INVALID_URL
                        }
                    } else {
                        let campaigns: [CGCampaigns] = (campaignsModel?.campaigns)!
                        let filteredArray = campaigns.filter{($0.campaignId.elementsEqual(local_id)) || ($0.banner != nil && $0.banner?.tag != nil && $0.banner?.tag != "" && ($0.banner!.tag!.elementsEqual(local_id)))}
                        if filteredArray.count > 0 {
                            nudgeConfiguration.url = filteredArray[0].url
                            if (filteredArray[0].url.count > 0 && (URL(string: filteredArray[0].url) != nil)){
                                cgstate = CGSTATE.SUCCESS
                            }else{
                                cgstate = CGSTATE.INVALID_CAMPAIGN
                            }
                            
                        } else {
                            // load wallet defaultwalleturl
                            nudgeConfiguration.url = defaultwalleturl
                            cgstate = CGSTATE.INVALID_CAMPAIGN
                        }
                    }
                }else{
                    // load wallet defaultwalleturl
                    nudgeConfiguration.url = defaultwalleturl
                    cgstate = CGSTATE.SUCCESS
                }
                DispatchQueue.main.async { [self] in // Make sure you're on the main thread here
                    self.presentToCustomerWebViewController(nudge_url: nudgeConfiguration.url, page_type: nudgeConfiguration.layout, backgroundAlpha: nudgeConfiguration.opacity,auto_close_webview: nudgeConfiguration.closeOnDeepLink)
                    
                    if (CGSTATE.SUCCESS == cgstate){
                        completion(cgstate, "", cgdeeplink)
                        
                    }else{
                        completion(cgstate, "", nil)
                        
                    }
                    
                }
                
            } else {
                completion(CGSTATE.EXCEPTION, "Fail to call loadAllCampaignsApi / Invalid response", nil)
                CustomerGlu.getInstance.printlog(cglog: "Fail to load loadAllCampaignsApi", isException: false, methodName: "CustomerGlu-excecuteDeepLink", posttoserver: true)
            }
        }
    }
    
    @objc public func openDeepLink(deepURLType: CGDeeplinkURLType, id: String, completion: @escaping (CGSTATE, String, CGDeeplinkData?) -> Void) {
        var urlString = ""
        if deepURLType == .wallet {
            urlString = "w"
        } else if deepURLType == .campaign {
            urlString = "c"
        } else if deepURLType == .link {
            urlString = "u"
        }
        guard !urlString.isEmpty else {
            completion(CGSTATE.EXCEPTION, "Incorrect Invalide URL", nil)
            return
        }
        getCGDeeplinkData(withID: id, urlType: urlString, completion: completion)
    }
    
    //    getCGDeeplinkData
    //(eventNudge: [String: Any], completion: @escaping (Bool, CGAddCartModel?) -> Void)
    @objc public func openDeepLink(deepurl:URL!, completion: @escaping (CGSTATE, String, CGDeeplinkData?) -> Void) {
        
        //            SUCCESS,
        //            USER_NOT_SIGNED_IN,
        //            INVALID_URL,
        //            INVALID_CAMPAIGN,
        //            CAMPAIGN_UNAVAILABLE,
        //            NETWORK_EXCEPTION,
        //            EXCEPTION
        if(deepurl != nil && deepurl.scheme != nil && deepurl.scheme!.count > 0 && (((deepurl.scheme!.lowercased() == "http") || deepurl.scheme!.lowercased() == "https") == true) && deepurl.host != nil && deepurl.host!.count > 0 && (deepurl.host!.lowercased().contains(".cglu.") == true)){
            
            let firstpath = deepurl.pathComponents.count > 1 ? deepurl.pathComponents[1].lowercased() : ""
            let secondpath = deepurl.pathComponents.count > 2 ? deepurl.pathComponents[2] : ""
            
            if((firstpath.count > 0 && (firstpath == "c" || firstpath == "w" || firstpath == "u")) && secondpath.count > 0) {
                getCGDeeplinkData(withID: secondpath, urlType: firstpath, completion: completion)
            }else{
                completion(CGSTATE.INVALID_URL, "Incorrect URL", nil)
            }
            
        }else{
            completion(CGSTATE.EXCEPTION, "Incorrect Invalide URL", nil)
        }
    }
                         
    private func getCGDeeplinkData(withID id: String, urlType: String, completion: @escaping (CGSTATE, String, CGDeeplinkData?) -> Void) {
        CustomerGlu.getInstance.loaderShow(withcoordinate: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        APIManager.getCGDeeplinkData(queryParameters: ["id": id]) { result in
            CustomerGlu.getInstance.loaderHide()
            switch result {
            case .success(let response):
                if(response.success == true){
                    if (response.data != nil){
                        if(response.data!.anonymous == true){
                            CustomerGlu.getInstance.allowAnonymousRegistration(enabled: true)
                            if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil{
                                self.excecuteDeepLink(firstpath: urlType, cgdeeplink: response.data!, completion: completion)
                            }else{
                                // Reg Call then exe
                                var userData = [String: AnyHashable]()
                                userData["userId"] = ""
                                CustomerGlu.getInstance.loaderShow(withcoordinate: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                                self.registerDevice(userdata: userData) { success in
                                    CustomerGlu.getInstance.loaderHide()
                                    if success {
                                        self.excecuteDeepLink(firstpath: urlType, cgdeeplink: response.data!, completion: completion)
                                    } else {
                                        CustomerGlu.getInstance.printlog(cglog: "Fail to call getCGDeeplinkData", isException: false, methodName: "CustomerGlu-openDeepLink-5", posttoserver: false)
                                        completion(CGSTATE.EXCEPTION,"Fail to calll register user", nil)
                                    }
                                }
                            }
                        }else{
                            if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil && false == ApplicationManager.isAnonymousUesr(){
                                self.excecuteDeepLink(firstpath: urlType, cgdeeplink: response.data!, completion: completion)
                            }else{
                                CustomerGlu.getInstance.printlog(cglog: "Fail to call getCGDeeplinkData", isException: false, methodName: "CustomerGlu-openDeepLink-5", posttoserver: false)
                                completion(CGSTATE.USER_NOT_SIGNED_IN,"", nil)
                            }
                        }
                        
                    }else{
                        CustomerGlu.getInstance.printlog(cglog: "Fail to call getCGDeeplinkData", isException: false, methodName: "CustomerGlu-openDeepLink-4", posttoserver: false)
                        completion(CGSTATE.EXCEPTION, "Invalid Response", nil)
                    }
                    
                }else{
                    CustomerGlu.getInstance.printlog(cglog: "Fail to call getCGDeeplinkData", isException: false, methodName: "CustomerGlu-openDeepLink-2", posttoserver: false)
                    completion(CGSTATE.EXCEPTION, response.message ?? "", nil)
                }
                
            case .failure(_):
                CustomerGlu.getInstance.printlog(cglog: "Fail to call getCGDeeplinkData", isException: false, methodName: "CustomerGlu-openDeepLink-3", posttoserver: false)
                completion(CGSTATE.EXCEPTION, "Fail to call getCGDeeplinkData / Invalid response", nil)
            }
        }
    }
                         
    @objc public func openWallet(nudgeConfiguration: CGNudgeConfiguration) {
        var eventData: [String: Any] = [:]
        eventData["nudgeConfiguration"] = nudgeConfiguration
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_OPEN_WALLET_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        CustomerGlu.getInstance.loadCampaignById(campaign_id: CGConstants.CGOPENWALLET, nudgeConfiguration:nudgeConfiguration)
        
    }
    
    @objc public func openWallet(auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        var eventData: [String: Any] = [:]
        eventData["auto_close_webview"] = auto_close_webview
        CGEventsDiagnosticsHelper.shared .sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_OPEN_WALLET_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        CustomerGlu.getInstance.loadCampaignById(campaign_id: CGConstants.CGOPENWALLET, auto_close_webview: auto_close_webview)
    }
    
    @objc public func loadAllCampaigns(auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call loadAllCampaigns", isException: false, methodName: "CustomerGlu-loadAllCampaigns", posttoserver: true)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            loadAllCampign.auto_close_webview = auto_close_webview
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .overCurrentContext
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc public func loadCampaignById(campaign_id: String, nudgeConfiguration : CGNudgeConfiguration? = nil , auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        
        // Do Client Testing
        if campaign_id.caseInsensitiveCompare("test-integration") == .orderedSame {
            testIntegration()
            return
        }
        
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call loadCampaignById", isException: false, methodName: "CustomerGlu-loadCampaignById", posttoserver: true)
            return
        }
        
        // Check to open wallet or not in fallback case
        guard checkToOpenWalletOrNot(withCampaignID: campaign_id) else {
            return
        }
        
        var eventData: [String: Any] = [:]
        eventData["nudgeConfiguration"] = nudgeConfiguration
        eventData["campaign_id"] = campaign_id
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_LOAD_CAMPAIGN_BY_ID_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        DispatchQueue.main.async {
            let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            customerWebViewVC.auto_close_webview = nudgeConfiguration != nil ? nudgeConfiguration?.closeOnDeepLink : auto_close_webview
            customerWebViewVC.modalPresentationStyle = .overCurrentContext//.fullScreen
            customerWebViewVC.iscampignId = true
            customerWebViewVC.campaign_id = campaign_id
            customerWebViewVC.nudgeConfiguration = nudgeConfiguration
            
            if(nudgeConfiguration != nil){
                if(nudgeConfiguration!.layout == CGConstants.MIDDLE_NOTIFICATIONS || nudgeConfiguration!.layout == CGConstants.MIDDLE_NOTIFICATIONS_POPUP){
                    customerWebViewVC.ismiddle = true
                    customerWebViewVC.modalPresentationStyle = .overCurrentContext
                }else if(nudgeConfiguration!.layout == CGConstants.BOTTOM_DEFAULT_NOTIFICATION || nudgeConfiguration!.layout == CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP){
                    
                    customerWebViewVC.isbottomdefault = true
                    customerWebViewVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    customerWebViewVC.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    
                }else if(nudgeConfiguration!.layout == CGConstants.BOTTOM_SHEET_NOTIFICATION){
                    customerWebViewVC.isbottomsheet = true
#if compiler(>=5.5)
                    if #available(iOS 15.0, *) {
                        if let sheet = customerWebViewVC.sheetPresentationController {
                            sheet.detents = [ .medium(), .large() ]
                        }else{
                            customerWebViewVC.modalPresentationStyle = .pageSheet
                        }
                    } else {
                        customerWebViewVC.modalPresentationStyle = .pageSheet
                    }
#else
                    customerWebViewVC.modalPresentationStyle = .pageSheet
#endif
                }else{
                    customerWebViewVC.modalPresentationStyle = .overCurrentContext//.fullScreen
                }
            }
            self.hideFloatingButtons()
            topController.present(customerWebViewVC, animated: false, completion: nil)
        }
    }
    
    @objc public func loadCampaignsByType(type: String, auto_close_webview : Bool = CustomerGlu.auto_close_webview! ) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call loadCampaignsByType", isException: false, methodName: "CustomerGlu-loadCampaignsByType", posttoserver: true)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.auto_close_webview = auto_close_webview
            loadAllCampign.loadCampignType = APIParameterKey.type
            loadAllCampign.loadCampignValue = type
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .overCurrentContext
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc public func loadCampaignByFilter(parameters: NSDictionary, auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call loadCampaignByFilter", isException: false, methodName: "CustomerGlu-loadCampaignByFilter", posttoserver: true)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.loadByparams = parameters
            loadAllCampign.auto_close_webview = auto_close_webview
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .overCurrentContext
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc public func sendEventData(eventName: String, eventProperties: [String: Any]?) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call sendEventData", isException: false, methodName: "CustomerGlu-sendEventData-1", posttoserver: true)
            return
        }
        var eventData: [String: Any] = [:]
        var token: String? = ""
        if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil {
            token = UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) as! String
            eventData["token"] = token
        }else{
            eventData["token"] = token

        }
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_SEND_EVENT_START, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        ApplicationManager.sendEventData(eventName: eventName, eventProperties: eventProperties) { success, addCartModel in
            if success {
                if(true == CustomerGlu.isDebugingEnabled){
                    print(addCartModel as Any)
                }
            } else {
                CustomerGlu.getInstance.printlog(cglog: "Fail to call sendEventData", isException: false, methodName: "CustomerGlu-sendEventData-2", posttoserver: true)
            }
        }
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_SEND_EVENT_END, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
    }
    
    @available(*, deprecated,message:"Use configureSafeArea with Light and Dark mode support")
    @objc public func configureSafeArea(topHeight: Int, bottomHeight: Int, topSafeAreaColor: UIColor, bottomSafeAreaColor: UIColor) {
        var eventData: [String: Any] = [:]
        eventData["topHeight"] = topHeight
        eventData["bottomHeight"] = bottomHeight
        eventData["topSafeAreaColor"] = topSafeAreaColor
        eventData["bottomSafeAreaColor"] = bottomSafeAreaColor
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_CONFIGURE_SAFE_AREA_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        CustomerGlu.topSafeAreaHeight = topHeight
        CustomerGlu.bottomSafeAreaHeight = bottomHeight
        CustomerGlu.topSafeAreaColor = topSafeAreaColor
        CustomerGlu.bottomSafeAreaColor = bottomSafeAreaColor
    }
    
    @objc public func configureSafeArea(topHeight: Int, bottomHeight: Int, topSafeAreaLightColor: UIColor, bottomSafeAreaLightColor: UIColor, topSafeAreaDarkColor: UIColor, bottomSafeAreaDarkColor: UIColor) {
        var eventData: [String: Any] = [:]
        eventData["topHeight"] = topHeight
        eventData["bottomHeight"] = bottomHeight
        eventData["topSafeAreaLightColor"] = topSafeAreaLightColor
        eventData["bottomSafeAreaLightColor"] = bottomSafeAreaLightColor
        eventData["topSafeAreaDarkColor"] = topSafeAreaDarkColor
        eventData["bottomSafeAreaDarkColor"] = bottomSafeAreaDarkColor
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_CONFIGURE_SAFE_AREA_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        CustomerGlu.topSafeAreaHeight = topHeight
        CustomerGlu.bottomSafeAreaHeight = bottomHeight
        
        CustomerGlu.topSafeAreaColorLight = topSafeAreaLightColor
        CustomerGlu.bottomSafeAreaColorLight = bottomSafeAreaLightColor
        
        CustomerGlu.topSafeAreaColorDark = topSafeAreaDarkColor
        CustomerGlu.bottomSafeAreaColorDark = bottomSafeAreaDarkColor
    }
    
    private func addFloatingButton(btnInfo: CGData) {
        DispatchQueue.main.async {
            self.arrFloatingButton.append(FloatingButtonController(btnInfo: btnInfo))
        }
    }
    
    internal func hideFloatingButtons() {
        for floatBtn in self.arrFloatingButton {
            floatBtn.hideFloatingButton(ishidden: true)
        }
    }
    
    internal func dismissFloatingButtons(is_remove: Bool) {
        for floatBtn in self.arrFloatingButton {
            floatBtn.dismissFloatingButton(is_remove: is_remove)
        }
    }
    
    internal func showFloatingButtons() {
        CustomerGlu.getInstance.setCurrentClassName(className: CustomerGlu.getInstance.activescreenname)
    }
    
    internal func validateURL(url: URL) -> URL {
        let host = url.host
        if(host != nil && host!.count > 0){
            for str_url in CustomerGlu.whiteListedDomains {
                if (str_url.count > 0 && host!.hasSuffix(str_url)){
                    return url
                }
            }
        }
        
        return URL(string: ("\(CGConstants.default_redirect_url)?code=\(String(CustomerGlu.doamincode))&message=\(CustomerGlu.textMsg)"))!
    }
    
    @objc public func configureWhiteListedDomains(domains: [String]){
        CustomerGlu.whiteListedDomains = domains
        CustomerGlu.whiteListedDomains.append(CGConstants.default_whitelist_doamin)
    }
    
    
    @objc public func configureLightLoaderURL(locallottieLoaderURL: String){
        
        if(locallottieLoaderURL.count > 0 && URL(string: locallottieLoaderURL) != nil){
            CustomerGlu.lightLoaderURL = locallottieLoaderURL
            let url = URL(string: locallottieLoaderURL)
            CGFileDownloader.loadFileAsync(url: url!) { [self] (path, error) in
                if (error == nil){
                    encryptUserDefaultKey(str: path ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_LIGHT_LOTTIE_FILE_PATH)
                }
            }
        }
    }
    
    @objc public func configureDarkLoaderURL(locallottieLoaderURL: String){
        
        if(locallottieLoaderURL.count > 0 && URL(string: locallottieLoaderURL) != nil){
            CustomerGlu.darkLoaderURL = locallottieLoaderURL
            let url = URL(string: locallottieLoaderURL)
            CGFileDownloader.loadFileAsync(url: url!) { [self] (path, error) in
                if (error == nil){
                    encryptUserDefaultKey(str: path ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_DARK_LOTTIE_FILE_PATH)
                }
            }
        }
    }
    
    @objc public func configureLightEmbedLoaderURL(locallottieLoaderURL: String){
        
        if(locallottieLoaderURL.count > 0 && URL(string: locallottieLoaderURL) != nil){
            CustomerGlu.lightEmbedLoaderURL = locallottieLoaderURL
            let url = URL(string: locallottieLoaderURL)
            CGFileDownloader.loadFileAsync(url: url!) { [self] (path, error) in
                if (error == nil){
                    encryptUserDefaultKey(str: path ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_LIGHT_EMBEDLOTTIE_FILE_PATH)
                }
            }
        }
    }
    
    @objc public func configureDarkEmbedLoaderURL(locallottieLoaderURL: String){
        
        if(locallottieLoaderURL.count > 0 && URL(string: locallottieLoaderURL) != nil){
            CustomerGlu.darkEmbedLoaderURL = locallottieLoaderURL
            let url = URL(string: locallottieLoaderURL)
            CGFileDownloader.loadFileAsync(url: url!) { [self] (path, error) in
                if (error == nil){
                    encryptUserDefaultKey(str: path ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_DARK_EMBEDLOTTIE_FILE_PATH)
                }
            }
        }
    }
    
    @objc public func configureDomainCodeMsg(code: Int, message: String){
        CustomerGlu.doamincode = code
        CustomerGlu.textMsg = message
    }
    
    @objc public func setCurrentClassName(className: String) {
        
        if(popuptimer != nil){
            popuptimer?.invalidate()
            popuptimer = nil
        }
        
        if CustomerGlu.isEntryPointEnabled {
            if !configScreens.contains(className) {
                configScreens.append(className)

            }
            sendEntryPointsIdLists()
            
            CustomerGlu.getInstance.activescreenname = className
            
            for floatBtn in self.arrFloatingButton {
                floatBtn.hideFloatingButton(ishidden: true)
                if (floatBtn.floatInfo?.mobile.container.ios.allowedActitivityList.count)! > 0 && (floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.count)! > 0 {
                    if  !(floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.contains(className))! {
                        floatBtn.hideFloatingButton(ishidden: false)
                        callEventPublishNudge(data: floatBtn.floatInfo!, className: className, actionType: "LOADED", event_name: "ENTRY_POINT_LOAD")
                    }
                } else if (floatBtn.floatInfo?.mobile.container.ios.allowedActitivityList.count)! > 0 {
                    if (floatBtn.floatInfo?.mobile.container.ios.allowedActitivityList.contains(className))! {
                        floatBtn.hideFloatingButton(ishidden: false)
                        callEventPublishNudge(data: floatBtn.floatInfo!, className: className, actionType: "LOADED",event_name: "ENTRY_POINT_LOAD")
                    }
                } else if (floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.count)! > 0 {
                    if !(floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.contains(className))! {
                        floatBtn.hideFloatingButton(ishidden: false)
                        callEventPublishNudge(data: floatBtn.floatInfo!, className: className, actionType: "LOADED", event_name: "ENTRY_POINT_LOAD")
                    }
                }
            }
            
            showPopup(className: className)
        }
    }
    public func sendEntryPointsIdLists()
    {
        let user_id = decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID)
        
        if CustomerGlu.testUsers.contains(user_id) {
            // API Call Collect ViewController Name & Post
            var eventInfo = [String: AnyHashable]()
            eventInfo[APIParameterKey.activityIdList] = configScreens
            eventInfo[APIParameterKey.bannerIds] = CustomerGlu.bannerIds
            eventInfo[APIParameterKey.embedIds] = CustomerGlu.embedIds

            APIManager.entrypoints_config(queryParameters: eventInfo as NSDictionary) { result in
                switch result {
                case .success(let response):
                    if(true == CustomerGlu.isDebugingEnabled){
                        print(response)
                    }
                case .failure(let error):
                    CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-setCurrentClassName", posttoserver: true)
                }
            }
        }
    }
    
    private func addFloatingBtns() {
        // FLOATING Buttons
        let floatingButtons = popupDict.filter {
            $0.type == "FLOATING"
        }
        
        if floatingButtons.count != 0 {
            for floatBtn in floatingButtons {
                let floatButton = CustomerGlu.entryPointdata.filter {
                    $0._id == floatBtn._id
                }
                
                if floatButton.count > 0 && ((floatButton[0].mobile.content.count > 0) && (floatBtn.showcount?.count)! < floatButton[0].mobile.conditions.showCount.count) {
                    self.addFloatingButton(btnInfo: floatButton[0])
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                CustomerGlu.getInstance.setCurrentClassName(className: CustomerGlu.getInstance.activescreenname)
            })
            
        }
    }
    
    internal func postBannersCount() {
        
        var postInfo: [String: Any] = [:]
        
        let banners = CustomerGlu.entryPointdata.filter {
            $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId != nil && $0.mobile.container.bannerId.count > 0
        }
        
        if(banners.count > 0){
            for banner in banners {
                postInfo[banner.mobile.container.bannerId] = banner.mobile.content.count
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_BANNER_LOADED").rawValue), object: nil, userInfo: postInfo)
        
        let bannersforheight = CustomerGlu.entryPointdata.filter {
            $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId != nil && $0.mobile.container.bannerId.count > 0 && (Int($0.mobile.container.height)!) > 0 && $0.mobile.content.count > 0
        }
        if bannersforheight.count > 0 {
            CustomerGlu.bannersHeight = [String:Any]()
            for banner in bannersforheight {
                CustomerGlu.bannersHeight![banner.mobile.container.bannerId] = Int(banner.mobile.container.height)
            }
        }
        if (CustomerGlu.bannersHeight == nil) {
            CustomerGlu.bannersHeight = [String:Any]()
        }
    }
    
    internal func postEmbedsCount() {
        
        var postInfo: [String: Any] = [:]
        
        let banners = CustomerGlu.entryPointdata.filter {
            $0.mobile.container.type == "EMBEDDED" && $0.mobile.container.bannerId != nil && $0.mobile.container.bannerId.count > 0
        }
        
        if(banners.count > 0){
            for banner in banners {
                postInfo[banner.mobile.container.bannerId] = banner.mobile.content.count
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_EMBEDDED_LOADED").rawValue), object: nil, userInfo: postInfo)
        
        let bannersforheight = CustomerGlu.entryPointdata.filter {
            $0.mobile.container.type == "EMBEDDED" && $0.mobile.container.bannerId != nil && $0.mobile.container.bannerId.count > 0 /*&& (Int($0.mobile.container.height)!) > 0*/ && $0.mobile.content.count > 0
        }
        if bannersforheight.count > 0 {
            CustomerGlu.embedsHeight = [String:Any]()
            for banner in bannersforheight {
                //                CustomerGlu.embedsHeight![banner.mobile.container.bannerId] = Int(banner.mobile.container.height)
                CustomerGlu.embedsHeight![banner.mobile.container.bannerId] = Int(banner.mobile.content.first?.absoluteHeight ?? 0.0)
            }
        }
        if (CustomerGlu.embedsHeight == nil) {
            CustomerGlu.embedsHeight = [String:Any]()
        }
    }
    
    private func showPopup(className: String) {
        
        //POPUPS
        let popups = popupDict.filter {
            $0.type == "POPUP"
        }
        
        let sortedPopup = popups.sorted{$0.priority! > $1.priority!}
        
        if sortedPopup.count > 0 {
            for popupShow in sortedPopup {
                
                let finalPopUp = CustomerGlu.entryPointdata.filter {
                    $0._id == popupShow._id
                }
                
                if (finalPopUp.count > 0 && ((finalPopUp[0].mobile.content.count > 0) && (popupShow.showcount?.count)! < finalPopUp[0].mobile.conditions.showCount.count)) {
                    
                    var userInfo = [String: Any]()
                    userInfo["finalPopUp"] = (finalPopUp[0] )
                    userInfo["popupShow"] = (popupShow )
                    
                    if finalPopUp[0].mobile.container.ios.allowedActitivityList.count > 0 && finalPopUp[0].mobile.container.ios.disallowedActitivityList.count > 0 {
                        if !finalPopUp[0].mobile.container.ios.disallowedActitivityList.contains(className) {
                            if !popupDisplayScreens.contains(className) {
                                popuptimer = Timer.scheduledTimer(timeInterval: TimeInterval(finalPopUp[0].mobile.conditions.delay), target: self, selector: #selector(showPopupAfterTime(sender:)), userInfo: userInfo, repeats: false)
                                return
                            }
                        }
                    }  else if finalPopUp[0].mobile.container.ios.allowedActitivityList.count > 0 {
                        if finalPopUp[0].mobile.container.ios.allowedActitivityList.contains(className) {
                            
                            if !popupDisplayScreens.contains(className) {
                                popuptimer = Timer.scheduledTimer(timeInterval: TimeInterval(finalPopUp[0].mobile.conditions.delay), target: self, selector: #selector(showPopupAfterTime(sender:)), userInfo: userInfo, repeats: false)
                                return
                            }
                        }
                    } else if finalPopUp[0].mobile.container.ios.disallowedActitivityList.count > 0 {
                        
                        if !finalPopUp[0].mobile.container.ios.disallowedActitivityList.contains(className) {
                            
                            if !popupDisplayScreens.contains(className) {
                                popuptimer = Timer.scheduledTimer(timeInterval: TimeInterval(finalPopUp[0].mobile.conditions.delay), target: self, selector: #selector(showPopupAfterTime(sender:)), userInfo: userInfo, repeats: false)
                                
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    internal func updateShowCount(showCount: PopUpModel, eventData: CGData) {
        var showCountNew = showCount
        showCountNew.showcount?.count += 1
        
        if let index = popupDict.firstIndex(where: {$0._id == showCountNew._id}) {
            popupDict.remove(at: index)
            popupDict.insert(showCountNew, at: index)
        }
        
        entryPointPopUpModel.popups = popupDict
        
        var data: Data?
        
        do {
            data = try JSONEncoder().encode(entryPointPopUpModel)
        } catch(let error) {
            CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "updateShowCount", posttoserver: true)
        }
        
        guard let data = data, let jsonString2 = String(data: data, encoding: .utf8) else { return }
        encryptUserDefaultKey(str: jsonString2, userdefaultKey: CGConstants.CustomerGluPopupDict)
    }
    
    @objc private func showPopupAfterTime(sender: Timer) {
        if popuptimer != nil && !popupDisplayScreens.contains(CustomerGlu.getInstance.activescreenname) {
            
            let userInfo = sender.userInfo as! [String:Any]
            let finalPopUp = userInfo["finalPopUp"] as! CGData
            let showCount = userInfo["popupShow"] as! PopUpModel
            
            popuptimer?.invalidate()
            popuptimer = nil
            
            let nudgeConfiguration = CGNudgeConfiguration()
            nudgeConfiguration.layout = finalPopUp.mobile.content[0].openLayout.lowercased()
            nudgeConfiguration.opacity = finalPopUp.mobile.conditions.backgroundOpacity ?? 0.5
            nudgeConfiguration.closeOnDeepLink = finalPopUp.mobile.content[0].closeOnDeepLink ?? CustomerGlu.auto_close_webview!
            nudgeConfiguration.relativeHeight = finalPopUp.mobile.content[0].relativeHeight ?? 0.0
            nudgeConfiguration.absoluteHeight = finalPopUp.mobile.content[0].absoluteHeight ?? 0.0
            
            CustomerGlu.getInstance.openCampaignById(campaign_id: (finalPopUp.mobile.content[0].campaignId), nudgeConfiguration: nudgeConfiguration)
            
            self.popupDisplayScreens.append(CustomerGlu.getInstance.activescreenname)
            updateShowCount(showCount: showCount, eventData: finalPopUp)
            callEventPublishNudge(data: finalPopUp, className: CustomerGlu.getInstance.activescreenname, actionType: "OPEN", event_name: "ENTRY_POINT_LOAD")
        }
    }
    
    internal func callEventPublishNudge(data: CGData, className: String, actionType: String, event_name:String) {
        
        if(event_name == "ENTRY_POINT_LOAD" && data.mobile.container.type == "POPUP"){
            postAnalyticsEventForEntryPoints(event_name: event_name, entry_point_id: data.mobile.content[0]._id, entry_point_name: data.name , entry_point_container: data.mobile.container.type, content_campaign_id: data.mobile.content[0].campaignId, open_container: data.mobile.content[0].openLayout, action_c_campaign_id: data.mobile.content[0].campaignId)
        }else{
            postAnalyticsEventForEntryPoints(event_name: event_name, entry_point_id: data.mobile.content[0]._id, entry_point_name: data.name , entry_point_container: data.mobile.container.type, content_campaign_id: data.mobile.content[0].url, open_container: data.mobile.content[0].openLayout, action_c_campaign_id: data.mobile.content[0].campaignId)
        }
        
    }
    
    internal func openCampaignById(campaign_id: String, nudgeConfiguration : CGNudgeConfiguration) {
        
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.iscampignId = true
        customerWebViewVC.alpha = nudgeConfiguration.opacity
        customerWebViewVC.campaign_id = campaign_id
        customerWebViewVC.auto_close_webview = nudgeConfiguration.closeOnDeepLink
        customerWebViewVC.nudgeConfiguration = nudgeConfiguration
        guard let topController = UIViewController.topViewController() else {
            return
        }
        
        if (nudgeConfiguration.layout == CGConstants.BOTTOM_SHEET_NOTIFICATION) {
            customerWebViewVC.isbottomsheet = true
#if compiler(>=5.5)
            if #available(iOS 15.0, *) {
                if let sheet = customerWebViewVC.sheetPresentationController {
                    sheet.detents = [ .medium(), .large() ]
                }else{
                    customerWebViewVC.modalPresentationStyle = .pageSheet
                }
            } else {
                customerWebViewVC.modalPresentationStyle = .pageSheet
            }
#else
            customerWebViewVC.modalPresentationStyle = .pageSheet
#endif
        } else if ((nudgeConfiguration.layout == CGConstants.BOTTOM_DEFAULT_NOTIFICATION) || (nudgeConfiguration.layout == CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP)) {
            customerWebViewVC.isbottomdefault = true
            customerWebViewVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customerWebViewVC.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        } else if ((nudgeConfiguration.layout == CGConstants.MIDDLE_NOTIFICATIONS) || (nudgeConfiguration.layout == CGConstants.MIDDLE_NOTIFICATIONS_POPUP)) {
            customerWebViewVC.ismiddle = true
            customerWebViewVC.modalPresentationStyle = .overCurrentContext
        } else {
            customerWebViewVC.modalPresentationStyle = .overCurrentContext//.fullScreen
        }
        topController.present(customerWebViewVC, animated: true) {
            CustomerGlu.getInstance.hideFloatingButtons()
        }
    }
    
    internal func postAnalyticsEventForEntryPoints(event_name:String, entry_point_id:String, entry_point_name:String, entry_point_container:String, content_campaign_id:String = "", action_type: String = "OPEN", open_container:String, action_c_campaign_id:String) {
        if (false == CustomerGlu.analyticsEvent) {
            return
        }
        
        if(("ENTRY_POINT_DISMISS" == event_name) || ("ENTRY_POINT_LOAD" == event_name) || ("ENTRY_POINT_CLICK" == event_name)){
            
            var eventInfo = [String: Any]()
            eventInfo[APIParameterKey.event_name] = event_name
            var entry_point_data = [String: Any]()
            
            entry_point_data[APIParameterKey.entry_point_id] = entry_point_id
            entry_point_data[APIParameterKey.entry_point_name] = entry_point_name
            entry_point_data[APIParameterKey.entry_point_location] = CustomerGlu.getInstance.activescreenname
            
            if(("ENTRY_POINT_LOAD" == event_name) || ("ENTRY_POINT_CLICK" == event_name)){
                
                entry_point_data[APIParameterKey.entry_point_container] = entry_point_container
                var entry_point_content = [String: String]()
                
                
                var static_url_ec = ""
                var campaign_id_ec = ""
                var type_ec = ""
                if content_campaign_id.count == 0 {
                    type_ec = "WALLET"
                } else if content_campaign_id.contains("http://") || content_campaign_id.contains("https://"){
                    type_ec = "STATIC"
                    static_url_ec = content_campaign_id
                } else {
                    type_ec = "CAMPAIGN"
                    campaign_id_ec = content_campaign_id
                }
                entry_point_content[APIParameterKey.type] = type_ec
                entry_point_content[APIParameterKey.campaign_id] = campaign_id_ec
                entry_point_content[APIParameterKey.static_url] = static_url_ec
                
                entry_point_data[APIParameterKey.entry_point_content] = entry_point_content
                
                if(("ENTRY_POINT_CLICK" == event_name)){
                    
                    var entry_point_action = [String: Any]()
                    entry_point_action[APIParameterKey.action_type] = action_type
                    entry_point_action[APIParameterKey.open_container] = open_container
                    
                    var open_content = [String: String]()
                    var static_url = ""
                    var campaign_id = ""
                    var type = ""
                    if action_c_campaign_id.count == 0 {
                        type = "WALLET"
                    } else if action_c_campaign_id.contains("http://") || action_c_campaign_id.contains("https://"){
                        type = "STATIC"
                        static_url = action_c_campaign_id
                    } else {
                        type = "CAMPAIGN"
                        campaign_id = action_c_campaign_id
                    }
                    open_content[APIParameterKey.type] = type
                    open_content[APIParameterKey.static_url] = static_url
                    open_content[APIParameterKey.campaign_id] = campaign_id
                    
                    entry_point_action[APIParameterKey.open_content] = open_content
                    entry_point_data[APIParameterKey.entry_point_action] = entry_point_action
                }
            }
            eventInfo[APIParameterKey.entry_point_data] = entry_point_data
            ApplicationManager.sendAnalyticsEvent(eventNudge: eventInfo) { success, _ in
                if success {
                    CustomerGlu.getInstance.printlog(cglog: String(success), isException: false, methodName: "postAnalyticsEventForEntryPoints", posttoserver: false)
                } else {
                    CustomerGlu.getInstance.printlog(cglog: "Fail to call sendAnalyticsEvent ", isException: false, methodName: "postAnalyticsEventForBanner", posttoserver: true)
                }
            }
            
        }else{
            CustomerGlu.getInstance.printlog(cglog: "Invalid event_name", isException: false, methodName: "postAnalyticsEventForBanner", posttoserver: true)
            return
        }
    }
    
    internal func postAnalyticsEventForNotification(userInfo: [String: AnyHashable]) {
        if (false == CustomerGlu.analyticsEvent) {
            return
        }
        var eventInfo = [String: Any]()
        var nudge = [String: String]()
        
        let nudge_id = userInfo[APIParameterKey.nudge_id] as? String ?? ""
        let campaign_id = userInfo[APIParameterKey.campaign_id] as? String ?? ""
        let title = userInfo[APIParameterKey.title] as? String ?? ""
        let body = userInfo[APIParameterKey.body] as? String ?? ""
        
        let nudge_url = userInfo[NotificationsKey.nudge_url] as? String ?? ""
        let nudge_layout = userInfo[NotificationsKey.page_type] as? String ?? ""
        let type = userInfo[NotificationsKey.glu_message_type] as? String ?? ""
        
        nudge[APIParameterKey.nudgeId] = type
        if(type == NotificationsKey.in_app){
            eventInfo[APIParameterKey.event_name] = "NOTIFICATION_LOAD"
        }else{
            if (UIApplication.shared.applicationState == .active){
                eventInfo[APIParameterKey.event_name] = "NOTIFICATION_LOAD"
            }else{
                eventInfo[APIParameterKey.event_name] = "PUSH_NOTIFICATION_CLICK"
            }
        }
        
        nudge[APIParameterKey.nudgeId] = nudge_id
        nudge[APIParameterKey.campaign_id] = campaign_id
        nudge[APIParameterKey.title] = title
        nudge[APIParameterKey.body] = body
        nudge[APIParameterKey.nudge_layout] = nudge_layout
        nudge[APIParameterKey.click_action] = nudge_url
        nudge[APIParameterKey.type] = type
        eventInfo[APIParameterKey.nudge] = nudge
        
        ApplicationManager.sendAnalyticsEvent(eventNudge: eventInfo) { success, _ in
            if success {
                CustomerGlu.getInstance.printlog(cglog: String(success), isException: false, methodName: "postAnalyticsEventForNotification", posttoserver: false)
            } else {
                CustomerGlu.getInstance.printlog(cglog: "Fail to call sendAnalyticsEvent ", isException: false, methodName: "postAnalyticsEventForNotification", posttoserver: true)
            }
        }
    }
    
    internal func printlog(cglog: String = "", isException: Bool = false, methodName: String = "",posttoserver:Bool = false) {
        if(true == CustomerGlu.isDebugingEnabled){
            print("CG-LOGS: "+methodName+" : "+cglog)
        }
        
        if(true == posttoserver){
            ApplicationManager.callCrashReport(cglog: cglog, isException: isException, methodName: methodName, user_id:  decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID))
            
            APIManager.crashReport(queryParameters: ["Method Name" : methodName, "CGLog" : cglog]) { _ in }
        }
    }
    
    private func migrateUserDefaultKey() {
        if userDefaults.object(forKey: CGConstants.CUSTOMERGLU_TOKEN_OLD) != nil {
            encryptUserDefaultKey(str: UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN_OLD) as! String, userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN)
            userDefaults.removeObject(forKey: CGConstants.CUSTOMERGLU_TOKEN_OLD)
        }
        
        if userDefaults.object(forKey: CGConstants.CUSTOMERGLU_USERID_OLD) != nil {
            encryptUserDefaultKey(str: UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_USERID_OLD) as! String, userdefaultKey: CGConstants.CUSTOMERGLU_USERID)
            userDefaults.removeObject(forKey: CGConstants.CUSTOMERGLU_USERID_OLD)
        }
        
        if userDefaults.object(forKey: CGConstants.CustomerGluCrash_OLD) != nil {
            do {
                // retrieving a value for a key
                if let data = userDefaults.data(forKey: CGConstants.CustomerGluCrash_OLD),
                   let crashItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Dictionary<String, Any> {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: crashItems, options: .prettyPrinted)
                        // here "jsonData" is the dictionary encoded in JSON data
                        let jsonString2 = String(data: jsonData, encoding: .utf8)!
                        encryptUserDefaultKey(str: jsonString2, userdefaultKey: CGConstants.CustomerGluCrash)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } catch {
                print(error)
            }
            userDefaults.removeObject(forKey: CGConstants.CustomerGluCrash_OLD)
        }
        
        if userDefaults.object(forKey: CGConstants.CustomerGluPopupDict_OLD) != nil {
            do {
                let popupItems = try userDefaults.getObject(forKey: CGConstants.CustomerGluPopupDict_OLD, castTo: EntryPointPopUpModel.self)
                popupDict = popupItems.popups!
            } catch {
                print(error.localizedDescription)
            }
            entryPointPopUpModel.popups = popupDict
            
            var data: Data?
            
            do {
                data = try JSONEncoder().encode(entryPointPopUpModel)
            } catch(let error) {
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "migrateUserDefaultKey", posttoserver: true)
            }
            
            guard let data = data, let jsonString2 = String(data: data, encoding: .utf8) else { return }
            encryptUserDefaultKey(str: jsonString2, userdefaultKey: CGConstants.CustomerGluPopupDict)
            userDefaults.removeObject(forKey: CGConstants.CustomerGluPopupDict_OLD)
        }
    }
    
    
    private func encryptUserDefaultKey(str: String, userdefaultKey: String) {
        self.userDefaults.set(EncryptDecrypt.shared.encryptText(str: str), forKey: userdefaultKey)
    }
    
    @objc public func decryptUserDefaultKey(userdefaultKey: String) -> String {
        guard
            UserDefaults.standard.object(forKey: userdefaultKey) != nil,
            let value = UserDefaults.standard.string(forKey: userdefaultKey)
        else { return "" }
        
        return EncryptDecrypt.shared.decryptText(str: value)
    }
    
    @objc public func testIntegration() {
        launchClientTesting()
    }
    
    private func launchClientTesting(isDeeplinkRelaunch: Bool = false) {
        DispatchQueue.main.async {
            let clientTestingVC = StoryboardType.main.instantiate(vcType: CGClientTestingViewController.self)
            clientTestingVC.viewModel.isRelaunch = isDeeplinkRelaunch
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: clientTestingVC)
            navController.modalPresentationStyle = .overCurrentContext
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: - MQTT Setup
    private func initializeMqtt() {
        // Check if client id is in the preferences, if not there then register
        if let clientID = CustomerGlu.getInstance.cgUserData.client, let userID = CustomerGlu.getInstance.cgUserData.userId {
            // If client id is not nil, than setup MQTT
            /*
             - The topics to be subscribed in MQTT are as follows -
                 - **User level**   `/nudges/<client-id>/sha256(userID)` (Used for Event based Nudges)
                 - **Client level**  `/state/global/<client-id>`
             */
            let userTopic = "nudges/" + (clientID) + "/" + (userID.sha256())
            let clientTopic = "/state/global/" + (clientID)
            let host = "hermes.customerglu.com"
            let username = userID
            let password = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN)
            let mqttIdentifier = decryptUserDefaultKey(userdefaultKey: CGConstants.MQTT_Identifier)

            let config = CGMqttConfig(username: username, password: password, serverHost: host, topics: [userTopic, clientTopic], port: 1883, mqttIdentifier: mqttIdentifier)
            CGMqttClientHelper.shared.setupMQTTClient(withConfig: config, delegate: self)
        } else {
            // Client ID is not available - register
            var userData = [String: AnyHashable]()
            userData["userId"] = CustomerGlu.getInstance.cgUserData.userId ?? ""
            self.registerDevice(userdata: userData) { success in
                if success {
                    // Initialize Mqtt
                    self.initializeMqtt()
                }
            }
        }
    }
    
    func doLoadCampaignAndEntryPointCall() {
        ApplicationManager.openWalletApi { success, response in
            if success {
                self.getEntryPointData()
            }
        }
    }
    
    internal func showClientTestingRedirectAlert() {
        // After 8 seconds show redirect alert
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { [weak self] in
            guard let topController = UIViewController.topViewController() else {
                return
            }
            
            let customAlert = CGCustomAlert()
            customAlert.alertTitle = "Client Testing"
            customAlert.alertMessage = "Relaunch client testing after successful deeplink redirect!"
            customAlert.alertTag = 1001
            customAlert.isCancelButtonHidden = true
            customAlert.okButtonTitle = "Relaunch"
            customAlert.cancelButtonTitle = ""
            customAlert.isCancelButtonHidden = true
            customAlert.delegate = self
            customAlert.isRetry = false
            customAlert.showOnViewController(topController)
        }
    }
}

// MARK: - CGCustomAlertDelegate
extension CustomerGlu: CGCustomAlertDelegate {
    func okButtonPressed(_ alert: CGCustomAlert, alertTag: Int) {
        // Doing it after delay because topController is 'CGCustomAlert' and client testing wont open back
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.launchClientTesting(isDeeplinkRelaunch: true)
        }
    }
    
    func cancelButtonPressed(_ alert: CGCustomAlert, alertTag: Int) {}
}

// MARK: - CGMqttClientDelegate
extension CustomerGlu: CGMqttClientDelegate {
    func openScreen(_ screenType: CGMqttLaunchScreenType, withMqttMessage mqttMessage: CGMqttMessage?) {
        switch screenType {
        case .ENTRYPOINT:
            // Check Mqtt Enabled Components
            if checkMqttEnabledComponents(containsKey: CGConstants.MQTT_Enabled_Components_State_Sync) ||
                checkMqttEnabledComponents(containsKey: CGConstants.MQTT_Enabled_Components_EntryPoints) {
                // Entrypoint API refresh
                
                if  let enableMQTT =  self.appconfigdata?.enableMqtt, enableMQTT{
                    doLoadCampaignAndEntryPointCall()
                }
            }
            
        case .OPEN_CLIENT_TESTING_PAGE:
            // Open Client Testing Page
            self.testIntegration()
            
        case .CAMPAIGN_STATE_UPDATED,
                .USER_SEGMENT_UPDATED:
            // Check Mqtt Enabled Components
            if checkMqttEnabledComponents(containsKey: CGConstants.MQTT_Enabled_Components_State_Sync),  let enableMQTT =  self.appconfigdata?.enableMqtt, enableMQTT {
                // loadCampaign & Entrypoints API or user re-register
                ApplicationManager.openWalletApi { success, response in
                    if success {
                        self.getEntryPointData()
                    }
                }
            }
            
        case .SDK_CONFIG_UPDATED:
            // Check Mqtt Enabled Components
            if checkMqttEnabledComponents(containsKey: CGConstants.MQTT_Enabled_Components_State_Sync), let enableMQTT =  self.appconfigdata?.enableMqtt, enableMQTT {
                // SDK Config Updation call & SDK re-initialised.
                sdkInitialized = false // so the SDK can be re-initialised
                initializeSdk()
            }
        }
    }
    
    private func checkMqttEnabledComponents(containsKey key: String) -> Bool {
        if let mqttEnabledComponents = self.appconfigdata?.mqttEnabledComponents, mqttEnabledComponents.count > 0, mqttEnabledComponents.contains(key) {
            return true
        }
        
        return false
    }
}
