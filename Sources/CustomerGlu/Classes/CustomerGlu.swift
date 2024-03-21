import Foundation
import SwiftUI
import UIKit
import Lottie
import WebKit
import AVFoundation

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

@objc(CAMPAIGN_STATE)
public enum CAMPAIGN_STATE: Int {
  case IN_PROGRESS,
       PRISTINE,
       COMPLETED,
       NOT_ELIGIBLE
}

@objc(CAMPAIGNDATA)
public enum CAMPAIGNDATA: Int{
    case API,
    CACHE
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
    lazy var spinner : SpinnerView? = {
        return SpinnerView()
    }()
    var progressView = LottieAnimationView()
    var arrFloatingButton = [FloatingButtonController]()
    var activePIPView: CGPictureInPictureViewController?
    
    // Singleton Instance
    @objc public static var getInstance = CustomerGlu()
    public var sdk_disable: Bool? = false
    public  var sentryDSN: String = CGConstants.CGSENTRYDSN
    public  var isDiagnosticsEnabled: Bool? = false
    public  var isMetricsEnabled: Bool? = true
    public  var isCrashLogsEnabled: Bool? = true
    public  var sentry_enable: Bool? = false
    public  var enableDarkMode: Bool? = false
    public  var listenToSystemDarkMode: Bool? = false
    @objc public  var fcm_apn = ""
    public  var analyticsEvent: Bool? = false
    let userDefaults = UserDefaults.standard
    @objc public var apnToken = ""
    @objc public var fcmToken = ""
    @objc public  var defaultBannerUrl = ""
    @objc public  var arrColor = [UIColor(red: (101/255), green: (220/255), blue: (171/255), alpha: 1.0)]
    public  var auto_close_webview: Bool? = false
    @objc public  var topSafeAreaHeight = 44
    @objc public  var bottomSafeAreaHeight = 34
    @objc public  var topSafeAreaColor = UIColor.white
    @objc public  var bottomSafeAreaColor = UIColor.white
    @objc public  var topSafeAreaColorLight = UIColor.white
    @objc public  var topSafeAreaColorDark = UIColor.black
    @objc public  var bottomSafeAreaColorDark = UIColor.black
    @objc public  var bottomSafeAreaColorLight = UIColor.white
    public  var entryPointdata: [CGData] = []
    @objc public  var isDebugingEnabled = false
    @objc public  var isEntryPointEnabled = false
    @objc public  var activeViewController = ""
    @objc public  var app_platform = "IOS"
    @objc public  var defaultBGCollor = UIColor.white
    @objc public  var lightBackground = UIColor.white
    @objc public  var darkBackground = UIColor.black
    @objc public  var sdk_version = APIParameterKey.cgsdkversionvalue
    public  var allCampaignsIds: [String] = []
    public static var  campaignsAvailable: CGCampaignsModel?
    internal var activescreenname = ""
    public  var bannersHeight: [String: Any]? = nil
    public  var embedsHeight: [String: Any]? = nil
    
    internal var appconfigdata: CGMobileData? = nil
    internal var popupDict = [PopUpModel]()
    internal var entryPointPopUpModel = EntryPointPopUpModel()
    internal var popupDisplayScreens = [String]()
    private var configScreens = [String]()
    private var popuptimer : Timer?
    private var delaySeconds: Double = 0
    public  var whiteListedDomains = [CGConstants.default_whitelist_doamin]
    public  var testUsers = [String]()
    public  var activityIdList = [String]()
    public  var bannerIds = [String]()
    public  var embedIds = [String]()
    public  var doamincode = 404
    public  var textMsg = "Requested-page-is-not-valid"
    public  var lightLoaderURL = ""
    public  var darkLoaderURL = ""
    public  var lightEmbedLoaderURL = ""
    public  var darkEmbedLoaderURL = ""
    public  var PiPVideoURL = ""
    @objc public var cgUserData = CGUser()
    private var sdkInitialized: Bool = false
    private  var isAnonymousFlowAllowed: Bool = false
    public  var oldCampaignIds = ""
    public  var delayForPIP = 0
    public  var floatingVerticalPadding = 50
    public  var verticalPadding = 0
    public  var horizontalPadding = 0
    public  var floatingHorizontalPadding = 10
    private var allowOpenWallet: Bool = true
    private var loadCampaignResponse: CGCampaignsModel?
    private var pipVideoLocalPath: String = ""
    private var isShowingExpandedPiP: Bool = false
    internal  var isPiPViewLoadedEventPushed = false
    
    internal static var sdkWriteKey: String = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String ?? ""
    
    private override init() {
        super.init()
        
        migrateUserDefaultKey()
        
        if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil {
            if self.isEntryPointEnabled {
                getEntryPointData()
            }
        }
        if !(decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_PIP_PATH).isEmpty){
            self.pipVideoLocalPath = decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_PIP_PATH)
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
//                    ApplicationManager.shared.callCrashReport(cglog: (crashItems["callStack"] as? String)!, isException: true, methodName: "CustomerGluCrash", user_id: decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID))
                }
            } catch {
                if self.isDebugingEnabled {
                    print("private override init()")
                }
            }
        }
    }
    
    internal func getPiPLocalPath()-> String{
        return pipVideoLocalPath
    }
    
    internal func updatePiPLocalPath(path : String){
        self.pipVideoLocalPath = path
        encryptUserDefaultKey(str: path, userdefaultKey: CGConstants.CUSTOMERGLU_PIP_PATH)
    }
    
    @objc public func gluSDKDebuggingMode(enabled: Bool) {
        self.isDebugingEnabled = enabled
    }
    
    @objc public func enableEntryPoints(enabled: Bool) {
      isEntryPointEnabled = enabled
        if isEntryPointEnabled {
            getEntryPointData()
        }
    }
    
    @objc public func allowAnonymousRegistration(enabled: Bool) {
        self.isAnonymousFlowAllowed = enabled
    }
    
    @objc public func allowAnonymousRegistration() -> Bool {
        self.isAnonymousFlowAllowed
    }
    
    @objc public func customerGluDidCatchCrash(with model: CrashModel) {
        
        self.printlog(cglog: "\(model)", isException: false, methodName: "CustomerGlu-customerGluDidCatchCrash-1", posttoserver: false)
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
        self.sdk_disable = disable
    }
    
    @objc public func enableDarkMode(isDarkModeEnabled: Bool){
        var eventData: [String: Any] = [:]
        eventData["enableDarkMode"] = isDarkModeEnabled
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_SET_DARK_MODE_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        self.enableDarkMode = isDarkModeEnabled
    }
    
    @objc public func isDarkModeEnabled()-> Bool {
        return self.checkIsDarkMode()
    }
    
    @objc public func listenToDarkMode(allowToListenDarkMode: Bool){
        var eventData: [String: Any] = [:]
        eventData["listenToDarkMode"] = self.listenToDarkMode
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_LISTEN_SYSTEM_DARK_MODE_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        self.listenToSystemDarkMode = allowToListenDarkMode
    }
    
    @objc public func isFcmApn(fcmApn: String) {
        self.fcm_apn = fcmApn
    }
    
    @objc public func setDefaultBannerImage(bannerUrl: String) {
        self.defaultBannerUrl = bannerUrl
    }
    
    @objc public func configureLoaderColour(color: [UIColor]) {
        var eventData: [String: Any] = [:]
        eventData["loaderColor"] = color
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_LOADER_COLOR_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        self.arrColor = color
    }
    @objc public func configureLoadingScreenColor(color: UIColor) {
        self.defaultBGCollor = color
    }
    @objc public func configureLightBackgroundColor(color: UIColor) {
        self.lightBackground = color
    }
    @objc public func configureDarkBackgroundColor(color: UIColor) {
        self.darkBackground = color
    }
    
    internal func checkIsDarkMode() -> Bool{
        
        if (true == self.enableDarkMode){
            return true
        }else{
            if(true == self.listenToSystemDarkMode){
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
                spinner?.removeFromSuperview()
                
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
                    let  localspinner = SpinnerView(frame: CGRect(x: x-30, y: y-30, width: 60, height: 60))
                    self.spinner = localspinner
                    controller.view.addSubview(localspinner)
                    controller.view.bringSubviewToFront(localspinner)
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
        self.auto_close_webview = close
    }
    
    @objc public func enableAnalyticsEvent(event: Bool) {
        var eventData: [String: Any] = [:]
        eventData["enableAnalyticsEvent"] = event
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_ENABLE_ANALYTICS_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData )
        self.analyticsEvent = event
    }
    
    func loaderHide() {
        DispatchQueue.main.async { [self] in
            if let controller = topMostController() {
                controller.view.isUserInteractionEnabled = true
                spinner?.removeFromSuperview()
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
        if self.sdk_disable! == true {
            return
        }
        let userInfo = notification.request.content.userInfo
        
        // Change this to your preferred presentation option
        if self.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            if userInfo[NotificationsKey.glu_message_type] as? String == "push" {
                
                if UIApplication.shared.applicationState == .active {
                    self.postAnalyticsEventForNotification(userInfo: userInfo as! [String:AnyHashable])
                    completionHandler([[.alert, .badge, .sound]])
                }
            }
        }
    }
    
    @objc public func setCrashLoggingEnabled(isCrashLoggingEnabled: Bool){
        self.isCrashLogsEnabled = isCrashLoggingEnabled
    }
    
    @objc public func setMetricsLoggingEnabled(isMetricsLoggingEnabled: Bool){
        self.isMetricsEnabled = isMetricsLoggingEnabled
    }
    
    @objc public func setDiagnosticsEnabled(isDiagnosticsEnabled: Bool){
        self.isDiagnosticsEnabled = isDiagnosticsEnabled
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
    
    @objc public func cgapplication(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], backgroundAlpha: Double = 0.5,auto_close_webview : Bool = true, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if self.sdk_disable! == true {
            self.printlog(cglog: "", isException: false, methodName: "CustomerGlu-cgapplication", posttoserver: true)
            return
        }
        if let messageID = userInfo[gcmMessageIDKey] {
            if(true == self.isDebugingEnabled){
                print("Message ID: \(messageID)")
            }
        }
        
        if self.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            let nudge_url = userInfo[NotificationsKey.nudge_url]
            if(true == self.isDebugingEnabled){
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
                nudgeConfiguration.closeOnDeepLink = Bool(closeOnDeepLink as! String) ?? self.auto_close_webview!
            }
            
            if userInfo[NotificationsKey.glu_message_type] as? String == NotificationsKey.in_app {
                
                if(true == self.isDebugingEnabled){
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
            self.hidePiPView()
        })
    }
    
    @objc public func setDelaySeconds(delaySeconds: Double) {
        self.delaySeconds = delaySeconds
    }
    
    @objc public func displayBackgroundNotification(remoteMessage: [String: AnyHashable],auto_close_webview : Bool = true) {
        if self.sdk_disable! == true {
            self.printlog(cglog: "", isException: false, methodName: "CustomerGlu-displayBackgroundNotification", posttoserver: false)
            return
        }
        
        if self.notificationFromCustomerGlu(remoteMessage: remoteMessage ) {
            let nudge_url = remoteMessage[NotificationsKey.nudge_url]
            if(true == self.isDebugingEnabled){
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
                nudgeConfiguration.closeOnDeepLink = Bool(closeOnDeepLink as! String) ?? self.auto_close_webview!
            }
            
            if(true == self.isDebugingEnabled){
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
        self.entryPointdata.removeAll()
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
        userDefaults.removeObject(forKey: CGConstants.allCampaignsIdsAsString)
        userDefaults.removeObject(forKey: CGConstants.CGGetRewardResponse)
        userDefaults.removeObject(forKey: CGConstants.CGGetProgramResponse)
        self.cgUserData = CGUser()
        ApplicationManager.shared.appSessionId = UUID().uuidString
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
            getAppConfig {[weak self] result in
                
            }
        }
    }
    
    @objc public func setWriteKey(_ writeKey: String) {
        CustomerGlu.sdkWriteKey = writeKey
    }
    
    @objc internal func getAppConfig(completion: @escaping (Bool) -> Void) {
        
        let eventInfo = [String: String]()
        var url =  "https://api.customerglu.com/client/v1/sdk/config"
        APIManager.shared.fetchDataFromURL(url){ data, error in
            if let error = error {
                print("Error fetching data:", error)
            } else if let data = data {
               print(data)
                // Parse the data here, for example, using JSONDecoder
            }
        }
        
//
//        APIManager.shared.appConfig(queryParameters: eventInfo as NSDictionary) {[weak self] result in
//            switch result {
//            case .success(let response):
//                if (response.data != nil && response.data?.mobile != nil) {
//                    self?.appconfigdata = (response.data?.mobile)!
//                    self?.updatedAllConfigParam()
//                }
//                completion(true)
//
//            case .failure(let error):
//                self?.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-getAppConfig", posttoserver: true)
//                completion(false)
//            }
//        }
        
        
    }
    
    
    func updatedAllConfigParam() -> Void{
        if(self.appconfigdata != nil) {
            if(self.appconfigdata!.disableSdk != nil){
                self.disableGluSdk(disable: (self.appconfigdata!.disableSdk ?? self.sdk_disable)!)
            }
            
            if self.appconfigdata!.isCrashLoggingEnabled != nil {
                self.setCrashLoggingEnabled(isCrashLoggingEnabled: (self.appconfigdata?.isCrashLoggingEnabled ?? self.isCrashLogsEnabled)!)
            }
            
            if self.appconfigdata?.isDiagnosticsEnabled != nil {
                self.setDiagnosticsEnabled(isDiagnosticsEnabled: (self.appconfigdata?.isDiagnosticsEnabled ?? self.isDiagnosticsEnabled)!)
            }
            
            if self.appconfigdata?.isMetricsEnabled != nil {
                self.setMetricsLoggingEnabled(isMetricsLoggingEnabled: (self.appconfigdata?.isMetricsEnabled ?? self.isMetricsEnabled)!)
            }
            
            if(self.appconfigdata!.enableAnalytics != nil){
                self.enableAnalyticsEvent(event: (self.appconfigdata!.enableAnalytics ?? self.analyticsEvent)!)
            }
            
            if let appconfigdata = self.appconfigdata, let sentrySecretData = appconfigdata.sentryDsn, let iOSSentryKey = sentrySecretData.iOS {
                self.sentryDSN = iOSSentryKey
            }
            
            if self.appconfigdata!.enableSentry != nil  {
                self.sentry_enable =  self.appconfigdata?.enableSentry ?? false
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
                self.enableEntryPoints(enabled: self.appconfigdata!.enableEntryPoints ?? self.isEntryPointEnabled)
            }
            
            if self.appconfigdata!.enableDarkMode != nil {
                self.enableDarkMode(isDarkModeEnabled: (self.appconfigdata!.enableDarkMode ?? self.enableDarkMode)!)
            }
            
            if self.appconfigdata!.listenToSystemDarkLightMode != nil {
                self.listenToDarkMode(allowToListenDarkMode: (self.appconfigdata!.listenToSystemDarkLightMode ?? self.listenToSystemDarkMode)!)
            }
            
            if(self.appconfigdata!.errorCodeForDomain != nil && self.appconfigdata!.errorMessageForDomain != nil){
                self.configureDomainCodeMsg(code: self.appconfigdata!.errorCodeForDomain ?? self.doamincode , message: self.appconfigdata!.errorMessageForDomain ?? self.textMsg)
            }
            
            if(self.appconfigdata!.iosSafeArea != nil){
                
                self.configureSafeArea(topHeight: Int(self.appconfigdata!.iosSafeArea?.newTopHeight ?? self.topSafeAreaHeight), bottomHeight: Int(self.appconfigdata!.iosSafeArea?.newBottomHeight ?? self.bottomSafeAreaHeight), topSafeAreaLightColor: UIColor(hex: self.appconfigdata!.iosSafeArea?.lightTopColor ?? self.topSafeAreaColor.hexString) ?? self.topSafeAreaColor, bottomSafeAreaLightColor: UIColor(hex: self.appconfigdata!.iosSafeArea?.lightBottomColor ?? self.bottomSafeAreaColor.hexString) ?? self.bottomSafeAreaColor, topSafeAreaDarkColor:  UIColor(hex: self.appconfigdata!.iosSafeArea?.darkTopColor ?? self.topSafeAreaColor.hexString) ?? self.topSafeAreaColor, bottomSafeAreaDarkColor: UIColor(hex: self.appconfigdata!.iosSafeArea?.darkBottomColor ?? self.bottomSafeAreaColor.hexString) ?? self.bottomSafeAreaColor)
                
                
            }
            
            if(self.appconfigdata!.loadScreenColor != nil){
                self.configureLoadingScreenColor(color: UIColor(hex: self.appconfigdata!.loadScreenColor ?? self.defaultBGCollor.hexString) ?? self.defaultBGCollor)
                
            }
            
            if let allowProxy = self.appconfigdata?.allowProxy {
                if allowProxy {
                    self.checkSSLCertificateExpiration()
                }
            }
            
            if(self.appconfigdata!.lightBackground != nil){
                self.configureLightBackgroundColor(color: UIColor(hex: self.appconfigdata!.lightBackground ?? self.lightBackground.hexString) ?? self.lightBackground)
            }
            
            if(self.appconfigdata!.darkBackground != nil){
                self.configureDarkBackgroundColor(color: UIColor(hex: self.appconfigdata!.darkBackground ?? self.darkBackground.hexString) ?? self.darkBackground)
            }
            
            if(self.appconfigdata!.loaderColor != nil){
                self.configureLoaderColour(color: [UIColor(hex: self.appconfigdata!.loaderColor ?? self.arrColor[0].hexString) ?? self.arrColor[0]])
            }
            
            if(self.appconfigdata!.whiteListedDomains != nil){
                self.configureWhiteListedDomains(domains: self.appconfigdata!.whiteListedDomains ?? self.whiteListedDomains)
            }
            
            if let loaderURLLight = self.appconfigdata?.loaderConfig?.loaderURL?.light {
                self.configureLightLoaderURL(locallottieLoaderURL: loaderURLLight)
            }
            
            if let loaderURLDark = self.appconfigdata?.loaderConfig?.loaderURL?.dark {
                self.configureDarkLoaderURL(locallottieLoaderURL: loaderURLDark)
            }
            
            if let embedLoaderURLLight = self.appconfigdata?.loaderConfig?.embedLoaderURL?.light {
                self.configureLightEmbedLoaderURL(locallottieLoaderURL: embedLoaderURLLight)
            }
            
            if let embedLoaderURLDark = self.appconfigdata?.loaderConfig?.embedLoaderURL?.dark {
                self.configureDarkEmbedLoaderURL(locallottieLoaderURL: embedLoaderURLDark)
            }
            
            if(self.appconfigdata!.activityIdList != nil && self.appconfigdata!.activityIdList?.ios != nil){
                self.configScreens = self.appconfigdata!.activityIdList?.ios ?? []
            }
            if(self.appconfigdata!.testUserIds != nil ){
                self.testUsers = self.appconfigdata!.testUserIds ?? []
            }
            if(self.appconfigdata!.bannerIds != nil && self.appconfigdata!.bannerIds?.ios != nil){
                self.bannerIds = self.appconfigdata!.bannerIds?.ios ?? []
            }
            if(self.appconfigdata!.embedIds != nil && self.appconfigdata!.embedIds?.ios != nil){
                self.embedIds = self.appconfigdata!.embedIds?.ios ?? []
            }
            
            if let allowAnonymousRegistration = self.appconfigdata?.allowAnonymousRegistration {
                self.isAnonymousFlowAllowed = allowAnonymousRegistration
            }
        }
    }
    
    @objc public func registerDevice(userdata: [String: AnyHashable], completion: @escaping (Bool) -> Void) {
        if self.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || (userdata[APIParameterKey.userId] == nil && !allowAnonymousRegistration()){
            self.printlog(cglog: "Fail to call registerDevice", isException: false, methodName: "CustomerGlu-registerDevice-1", posttoserver: true)
            self.bannersHeight = [String:Any]()
            self.embedsHeight = [String:Any]()
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
            if(true == self.isDebugingEnabled){
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
        
        if self.fcm_apn == "fcm" {
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
        
        APIManager.shared.userRegister(queryParameters: userData as NSDictionary) {[weak self] result in
            switch result {
            case .success(let response):
                if response.success! {
                    // Setup Sentry user
                    CGSentryHelper.shared.setupUser(userId: response.data?.user?.userId ?? "", clientId: response.data?.user?.client ?? "")
                    self?.encryptUserDefaultKey(str: response.data?.token ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN)
                    self?.encryptUserDefaultKey(str: response.data?.user?.userId ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_USERID)
                    self?.encryptUserDefaultKey(str: response.data?.user?.anonymousId ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_ANONYMOUSID)
                    
                    self?.cgUserData = response.data?.user ??     CGUser()
                    var data: Data?
                    do {
                        data = try JSONEncoder().encode(self?.cgUserData)
                    } catch(let error) {
                        self?.printlog(cglog: error.localizedDescription, isException: false, methodName: "registerDevice", posttoserver: true)
                    }
                    guard let data = data, let jsonString = String(data: data, encoding: .utf8) else { return }
                    self?.encryptUserDefaultKey(str: jsonString, userdefaultKey: CGConstants.CUSTOMERGLU_USERDATA)
                    self?.userDefaults.synchronize()
                    
                    if let enableMqtt = self?.appconfigdata?.enableMqtt, enableMqtt {
                        if CGMqttClientHelper.shared.checkIsMQTTConnected() {
                            CGMqttClientHelper.shared.disconnectMQTT()
                        }
                        self?.initializeMqtt()
                    }
                    self?.oldCampaignIds = self?.decryptUserDefaultKey(userdefaultKey: CGConstants.allCampaignsIdsAsString) ?? ""
                    self?.doloadCampaignsCall(){ value in
                        completion(value)
                    }
                } else {
                    self?.printlog(cglog: "", isException: false, methodName: "CustomerGlu-registerDevice-3", posttoserver: true)
                    self?.bannersHeight = [String:Any]()
                    self?.embedsHeight = [String:Any]()
                    completion(false)
                }
            case .failure(let error):
                self?.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-registerDevice-4", posttoserver: true)
                self?.bannersHeight = [String:Any]()
                self?.embedsHeight = [String:Any]()
                completion(false)
            }
        }
        eventData = [:]
        eventData["registerObject"] = userdata
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_USER_REGISTRATION_END, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
    }
    
    func doloadCampaignsCall(completion: @escaping (Bool) -> Void){
        ApplicationManager.shared.openWalletApi {[weak self] success, response in
            if success {
                CustomerGlu.campaignsAvailable = response
                if ((self?.isEntryPointEnabled) != nil) {
                    self?.bannersHeight = nil
                    self?.embedsHeight = nil
                    self?.doEntryPointCall(){ value in
                        completion(value)
                    }
                } else {
                    self?.bannersHeight = [String:Any]()
                    self?.embedsHeight = [String:Any]()
                    completion(true)
                }
                if let allowProxy = self?.appconfigdata?.allowProxy, allowProxy, self?.oldCampaignIds != self?.decryptUserDefaultKey(userdefaultKey: CGConstants.allCampaignsIdsAsString) {
                    CGProxyHelper.shared.getProgram()
                    CGProxyHelper.shared.getReward()
                }
            } else {
                self?.bannersHeight = [String:Any]()
                self?.embedsHeight = [String:Any]()
                completion(true)
            }
        }
    }
    func doEntryPointCall(completion: @escaping (Bool) -> Void){
        APIManager.shared.getEntryPointdata(queryParameters: ["consumer": "MOBILE"]) {[weak self] result in
            switch result {
            case .success(let responseGetEntry):
                DispatchQueue.main.async {
                    self?.dismissFloatingButtons(is_remove: false)
                }
                self?.entryPointdata.removeAll()
                self?.entryPointdata = responseGetEntry.data
                
                // FLOATING Buttons
                let floatingButtons = self?.entryPointdata.filter {
                    $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP" ||
                    $0.mobile.container.type == "PIP"
                }
                if let entrypointFilter = floatingButtons {
                    self?.entryPointInfoAddDelete(entryPoint: entrypointFilter)

                }

                
                self?.addFloatingBtns()
                self?.postBannersCount()
                self?.addPIPViews()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("EntryPointLoaded").rawValue), object: nil, userInfo: nil)
                completion(true)
                
            case .failure(let error):
                self?.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-registerDevice-2", posttoserver: true)
                self?.bannersHeight = [String:Any]()
                self?.embedsHeight = [String:Any]()
                completion(true)
            }
        }

    }
    
    @objc public func updateProfile(userdata: [String: AnyHashable], completion: @escaping (Bool) -> Void) {
        if self.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            self.printlog(cglog: "Fail to call updateProfile", isException: false, methodName: "CustomerGlu-updateProfile-1", posttoserver: true)
            self.bannersHeight = [String:Any]()
            self.embedsHeight = [String:Any]()
            completion(false)
            return
        }
        
        var userData = userdata
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            if(true == self.isDebugingEnabled){
                print(uuid)
            }
            userData[APIParameterKey.deviceId] = uuid
        }
        let user_id = decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID)
        if user_id.count < 0 {
            self.printlog(cglog: "user_id is nil", isException: false, methodName: "CustomerGlu-updateProfile-2", posttoserver: true)
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
        
        if self.fcm_apn == "fcm" {
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
        
        APIManager.shared.userRegister(queryParameters: userData as NSDictionary) { result in
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
                        self.printlog(cglog: error.localizedDescription, isException: false, methodName: "updateProfile", posttoserver: true)
                    }
                    
                    guard let data = data, let jsonString = String(data: data, encoding: .utf8) else { return }
                    self.encryptUserDefaultKey(str: jsonString, userdefaultKey: CGConstants.CUSTOMERGLU_USERDATA)
                    
                    self.userDefaults.synchronize()
                    
                    if self.isEntryPointEnabled {
                        self.bannersHeight = nil
                        self.embedsHeight = nil
                        APIManager.shared.getEntryPointdata(queryParameters: ["consumer": "MOBILE"]) { result in
                            switch result {
                            case .success(let responseGetEntry):
                                DispatchQueue.main.async {
                                    self.dismissFloatingButtons(is_remove: false)
                                }
                                self.entryPointdata.removeAll()
                                self.entryPointdata = responseGetEntry.data
                                
                                // FLOATING Buttons
                                let floatingButtons = self.entryPointdata.filter {
                                    $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP" || $0.mobile.container.type == "PIP"
                                }
                                
                                self.entryPointInfoAddDelete(entryPoint: floatingButtons)
                                self.addFloatingBtns()
                                self.addPIPViews()
                                self.postBannersCount()
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("EntryPointLoaded").rawValue), object: nil, userInfo: nil)
                                completion(true)
                                
                            case .failure(let error):
                                self.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-updateProfile-3", posttoserver: true)
                                self.bannersHeight = [String:Any]()
                                self.embedsHeight = [String:Any]()
                                completion(true)
                            }
                        }
                    } else {
                        self.bannersHeight = [String:Any]()
                        self.embedsHeight = [String:Any]()
                        completion(true)
                    }
                } else {
                    self.printlog(cglog: "", isException: false, methodName: "CustomerGlu-updateProfile-4", posttoserver: true)
                    self.bannersHeight = [String:Any]()
                    self.embedsHeight = [String:Any]()
                    completion(false)
                }
            case .failure(let error):
                self.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-updateProfile-5", posttoserver: true)
                self.bannersHeight = [String:Any]()
                self.embedsHeight = [String:Any]()
                completion(false)
            }
        }
    }
    
    
    /***
        Update Banner Id list
     */
    public func addBannerId(bannerId : String){
        if !self.bannerIds.contains(bannerId){
            self.bannerIds.append(bannerId)
        }
    }
    
    
    /***
        Update Embed Id list
     */
    public func addEmbedId(embedId : String){
        if !self.embedIds.contains(embedId){
            self.embedIds.append(embedId)
        }
    }

    private func getEntryPointData() {
        if sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            self.printlog(cglog: "Fail to call getEntryPointData", isException: false, methodName: "CustomerGlu-getEntryPointData", posttoserver: true)
            bannersHeight = [String:Any]()
            embedsHeight = [String:Any]()
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
    bannersHeight = nil
        embedsHeight = nil
        
        let queryParameters: [AnyHashable: Any] = ["consumer": "MOBILE"]
        
        
        APIManager.shared.getEntryPointdata(queryParameters: queryParameters as NSDictionary) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.dismissFloatingButtons(is_remove: false)
                }
                
                // Normal Flow
                self?.entryPointdata.removeAll()
                self?.entryPointdata = response.data
                
                // FLOATING Buttons
               let floatingButtons = self?.entryPointdata.filter {
                    $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP" || $0.mobile.container.type == "PIP"
                  

              }
                if let entrypointFilter = floatingButtons {
                    self?.entryPointInfoAddDelete(entryPoint: entrypointFilter)
                }
                

                self?.addFloatingBtns()
                self?.addPIPViews()
                self?.postBannersCount()
                
                /*
                 Below code only handles that scenario to show POPUP if it exists in API response.
                 */
                let popupData = self?.entryPointdata.filter {
                    $0.mobile.container.type == "POPUP"
                }
                
                if popupData?.count ?? 0 > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                        self?.setCurrentClassName(className:self?.activescreenname ?? "")
                    })
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("EntryPointLoaded").rawValue), object:    nil, userInfo: nil)

            case .failure(let error):
                self?.bannersHeight = [String:Any]()
                self?.embedsHeight = [String:Any]()
                self?.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-getEntryPointData", posttoserver: true)
            }
        }
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_GET_ENTRY_POINT_START, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
    }
    
//    private func doEntryPointAPICall() async throw -> [CGEntryPoint]{
//
//        guard let url = URL(string: "https://api.customerglu.com/entrypoints/v1/list?consumer=MOBILE") else { return }
//        var urlRequest = URLRequest(url: url)
//
//       let  (data,_) = try await URLSession.shared.dataTask(with: urlRequest)
//        let decoded = try JSONDecoder().decode(CGEntryPoint.self, from: data)
//    }
    
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
                self.printlog(cglog: error.localizedDescription, isException: false, methodName: "entryPointInfoAddDelete", posttoserver: true)
            }
            
            guard let data = data, let jsonString2 = String(data: data, encoding: .utf8) else { return }
            encryptUserDefaultKey(str: jsonString2, userdefaultKey: CGConstants.CustomerGluPopupDict)
        }
    }
    
    
    @objc public func isCampaignValid(campaignId: String, dataType: CAMPAIGNDATA, completion: @escaping ((Bool) -> ())){
        OtherUtils.shared.campaignValidationHelper(campaignId: campaignId, dataFlag: dataType, innerCompletion: { success in
            completion(success)
        })
       
    }
    
    @objc public func getCampaignStatus(campaignId: String, dataType: CAMPAIGNDATA, completion: @escaping ((CAMPAIGN_STATE) -> ())){
        OtherUtils.shared.getCampaignStatusHelper(campaignId: campaignId, dataFlag: dataType, innerCompletion: { campaignStatus in
            completion(campaignStatus)
        })
    }
    
    @objc public func openWalletWithURL(nudgeConfiguration: CGNudgeConfiguration) {
        self.presentToCustomerWebViewController(nudge_url: nudgeConfiguration.url, page_type: nudgeConfiguration.layout, backgroundAlpha: nudgeConfiguration.opacity,auto_close_webview: nudgeConfiguration.closeOnDeepLink)
    }
    
    @objc public func openWalletWithURL(url: String, auto_close_webview : Bool = true) {
        self.presentToCustomerWebViewController(nudge_url: url, page_type: CGConstants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: 0.5,auto_close_webview: auto_close_webview)
    }
    
    @objc public func openURLWithNudgeConfig(url: String, nudgeConfiguration: CGNudgeConfiguration){
        self.presentToCustomerWebViewController(nudge_url: url, page_type: nudgeConfiguration.layout, backgroundAlpha: nudgeConfiguration.opacity, auto_close_webview: nudgeConfiguration.closeOnDeepLink)
    }
    
    internal func openNudgeWithValidToken(nudgeId: String, layout: String = CGConstants.FULL_SCREEN_NOTIFICATION, bg_opacity: Double = 0.5, closeOnDeeplink : Bool = true, nudgeConfiguration : CGNudgeConfiguration? = nil) {
        if(nudgeId.count > 0 && self.sdk_disable == false){
            APIManager.shared.getWalletRewards(queryParameters: [:]) { result in
                switch result {
                case .success(let response):
                    // Save this - To open / not open wallet incase of failure / invalid campaignId in loadCampaignById
                    self.setCampaignsModel(response)
                    
                    if(response.defaultUrl.count > 0){
                        let url = URL(string: response.defaultUrl)
                        if(url != nil){
                            let scheme = url?.scheme
                            let host = url?.host
                            let userid = self.cgUserData.userId
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
                                    self.presentToCustomerWebViewController(nudge_url: finalurl!, page_type: nudgeConfiguration!.layout, backgroundAlpha: nudgeConfiguration!.opacity,auto_close_webview: nudgeConfiguration!.closeOnDeepLink, nudgeConfiguration: nudgeConfiguration)
                                    
                                }else{
                                    self.presentToCustomerWebViewController(nudge_url: finalurl!, page_type: cglayout, backgroundAlpha: bg_opacity,auto_close_webview: closeOnDeeplink)
                                }
                            }
                        }else{
                            self.printlog(cglog: "defaultUrl is not valid", isException: false, methodName: "openNudge-getWalletRewards", posttoserver: true)
                        }
                        
                    }else{
                        self.printlog(cglog: "defaultUrl not found", isException: false, methodName: "openNudge-getWalletRewards", posttoserver: true)
                    }
                    
                    break
                    
                case .failure(let error):
                    self.printlog(cglog: error.localizedDescription, isException: false, methodName: "openNudge-getWalletRewards", posttoserver: true)
                }
            }
        }else{
            self.printlog(cglog: "nudgeId / layout is not found OR SDK is disable", isException: false, methodName: "openNudge-getWalletRewards", posttoserver: true)
        }
    }
    @objc public func openNudge(nudgeId: String, nudgeConfiguration: CGNudgeConfiguration? = nil, layout: String = "full-default", bg_opacity: Double = 0.5, closeOnDeeplink : Bool = true) {
        
        var eventData: [String: Any] = [:]
        eventData["nudgeId"] = nudgeId
        eventData["nudgeConfiguration"] = nudgeConfiguration
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_OPEN_NUDGE_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        if ApplicationManager.shared.doValidateToken() == true {
            openNudgeWithValidToken(nudgeId: nudgeId, layout: layout, bg_opacity: bg_opacity, closeOnDeeplink: closeOnDeeplink,nudgeConfiguration: nudgeConfiguration)
        } else {
            let userData = [String: AnyHashable]()
            self.updateProfile(userdata: userData) { success in
                if success {
                    self.openNudgeWithValidToken(nudgeId: nudgeId, layout: layout, bg_opacity: bg_opacity, closeOnDeeplink: closeOnDeeplink,nudgeConfiguration: nudgeConfiguration)
                } else {
                    self.printlog(cglog: "UpdateProfile API fail", isException: false, methodName: "openNudge-updateProfile", posttoserver: true)
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
        
        self.loaderShow(withcoordinate: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        ApplicationManager.shared.loadAllCampaignsApi(type: "", value: "", loadByparams: [:]) { success, campaignsModel in
            self.loaderHide()
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
                self.printlog(cglog: "Fail to load loadAllCampaignsApi", isException: false, methodName: "CustomerGlu-excecuteDeepLink", posttoserver: true)
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
        self.loaderShow(withcoordinate: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        APIManager.shared.getCGDeeplinkData(queryParameters: ["id": id]) { result in
            self.loaderHide()
            switch result {
            case .success(let response):
                if(response.success == true){
                    if (response.data != nil){
                        if(response.data!.anonymous == true){
                            self.allowAnonymousRegistration(enabled: true)
                            if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil{
                                self.excecuteDeepLink(firstpath: urlType, cgdeeplink: response.data!, completion: completion)
                            }else{
                                // Reg Call then exe
                                var userData = [String: AnyHashable]()
                                userData["userId"] = ""
                                self.loaderShow(withcoordinate: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                                self.registerDevice(userdata: userData) { success in
                                    self.loaderHide()
                                    if success {
                                        self.excecuteDeepLink(firstpath: urlType, cgdeeplink: response.data!, completion: completion)
                                    } else {
                                        self.printlog(cglog: "Fail to call getCGDeeplinkData", isException: false, methodName: "CustomerGlu-openDeepLink-5", posttoserver: false)
                                        completion(CGSTATE.EXCEPTION,"Fail to calll register user", nil)
                                    }
                                }
                            }
                        }else{
                            if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil && false == ApplicationManager.shared.isAnonymousUesr(){
                                self.excecuteDeepLink(firstpath: urlType, cgdeeplink: response.data!, completion: completion)
                            }else{
                                self.printlog(cglog: "Fail to call getCGDeeplinkData", isException: false, methodName: "CustomerGlu-openDeepLink-5", posttoserver: false)
                                completion(CGSTATE.USER_NOT_SIGNED_IN,"", nil)
                            }
                        }
                        
                    }else{
                        self.printlog(cglog: "Fail to call getCGDeeplinkData", isException: false, methodName: "CustomerGlu-openDeepLink-4", posttoserver: false)
                        completion(CGSTATE.EXCEPTION, "Invalid Response", nil)
                    }
                    
                }else{
                    self.printlog(cglog: "Fail to call getCGDeeplinkData", isException: false, methodName: "CustomerGlu-openDeepLink-2", posttoserver: false)
                    completion(CGSTATE.EXCEPTION, response.message ?? "", nil)
                }
                
            case .failure(_):
                self.printlog(cglog: "Fail to call getCGDeeplinkData", isException: false, methodName: "CustomerGlu-openDeepLink-3", posttoserver: false)
                completion(CGSTATE.EXCEPTION, "Fail to call getCGDeeplinkData / Invalid response", nil)
            }
        }
    }
                         
    @objc public func openWallet(nudgeConfiguration: CGNudgeConfiguration) {
        var eventData: [String: Any] = [:]
        eventData["nudgeConfiguration"] = nudgeConfiguration
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_OPEN_WALLET_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        self.loadCampaignById(campaign_id: CGConstants.CGOPENWALLET, nudgeConfiguration:nudgeConfiguration)
        
    }
    
    @objc public func openWallet(auto_close_webview : Bool = true) {
        var eventData: [String: Any] = [:]
        eventData["auto_close_webview"] = auto_close_webview
        CGEventsDiagnosticsHelper.shared .sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_OPEN_WALLET_CALLED, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        self.loadCampaignById(campaign_id: CGConstants.CGOPENWALLET, auto_close_webview: auto_close_webview)
    }
    
    @objc public func loadAllCampaigns(auto_close_webview : Bool = true) {
        if self.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            self.printlog(cglog: "Fail to call loadAllCampaigns", isException: false, methodName: "CustomerGlu-loadAllCampaigns", posttoserver: true)
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
            self.hidePiPView()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc public func loadCampaignById(campaign_id: String, nudgeConfiguration : CGNudgeConfiguration? = nil , auto_close_webview : Bool = true) {
        
        // Do Client Testing
        if campaign_id.caseInsensitiveCompare("test-integration") == .orderedSame {
            testIntegration()
            return
        }
        
        if self.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            self.printlog(cglog: "Fail to call loadCampaignById", isException: false, methodName: "CustomerGlu-loadCampaignById", posttoserver: true)
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
            self.hidePiPView()
            topController.present(customerWebViewVC, animated: false, completion: nil)
        }
    }
    
    @objc public func loadCampaignsByType(type: String, auto_close_webview : Bool = true ) {
        if self.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            self.printlog(cglog: "Fail to call loadCampaignsByType", isException: false, methodName: "CustomerGlu-loadCampaignsByType", posttoserver: true)
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
            self.hidePiPView()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc public func loadCampaignByFilter(parameters: NSDictionary, auto_close_webview : Bool = true) {
        if self.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            self.printlog(cglog: "Fail to call loadCampaignByFilter", isException: false, methodName: "CustomerGlu-loadCampaignByFilter", posttoserver: true)
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
            self.hidePiPView()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc public func sendEventData(eventName: String, eventProperties: [String: Any]?) {
        if self.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: CGConstants.CUSTOMERGLU_TOKEN) == nil {
            self.printlog(cglog: "Fail to call sendEventData", isException: false, methodName: "CustomerGlu-sendEventData-1", posttoserver: true)
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
        ApplicationManager.shared.sendEventData(eventName: eventName, eventProperties: eventProperties) { success, addCartModel in
            if success {
                if(true == self.isDebugingEnabled){
                    print(addCartModel as Any)
                }
            } else {
                self.printlog(cglog: "Fail to call sendEventData", isException: false, methodName: "CustomerGlu-sendEventData-2", posttoserver: true)
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
        self.topSafeAreaHeight = topHeight
        self.bottomSafeAreaHeight = bottomHeight
        self.topSafeAreaColor = topSafeAreaColor
        self.bottomSafeAreaColor = bottomSafeAreaColor
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
        self.topSafeAreaHeight = topHeight
        self.bottomSafeAreaHeight = bottomHeight
        
        self.topSafeAreaColorLight = topSafeAreaLightColor
        self.bottomSafeAreaColorLight = bottomSafeAreaLightColor
        
        self.topSafeAreaColorDark = topSafeAreaDarkColor
        self.bottomSafeAreaColorDark = bottomSafeAreaDarkColor
    }
    
    private func addFloatingButton(btnInfo: CGData) {
        DispatchQueue.main.async {
            self.arrFloatingButton.append(FloatingButtonController(btnInfo: btnInfo))
        }
    }
    
    private func addPIPViewToUI(pipInfo: CGData)
    {
        if activePIPView == nil, !(self.topMostController() is CustomerWebViewController), !(self.topMostController() is CGPiPExpandedViewController) {
            if let videoURL = pipInfo.mobile.content[0].url {
                self.downloadPiPVideo(videoURL: videoURL, pipInfo: pipInfo)
            }
        }
    }
    
    internal func displayPiPFromCollapseCTA(with pipInfo: CGData, startTime: CMTime?) {
        isShowingExpandedPiP = false
        
        let controller = CGPictureInPictureViewController(btnInfo: pipInfo, startTime: startTime)
        controller.hidePiPButton(ishidden: false)
        activePIPView = controller
    }
    
    internal func showExpandedPiP(pipInfo: CGData, currentTime: CMTime?) {
        guard !isShowingExpandedPiP else { return }
        
        let clientTestingVC = StoryboardType.main.instantiate(vcType: CGPiPExpandedViewController.self)
        clientTestingVC.pipInfo = pipInfo
        clientTestingVC.startTime = currentTime
        guard let topController = UIViewController.topViewController() else {
            return
        }
        clientTestingVC.modalPresentationStyle = .fullScreen
        topController.present(clientTestingVC, animated: true, completion: nil)
        
        isShowingExpandedPiP = true
    }
    
    
    internal func hidePiPView() {
        activePIPView?.hidePiPButton(ishidden: true)
    }
    
    @objc public func addDelayForPIP(delay:Int){
        self.delayForPIP = delay
    }
    @objc public func addMarginForPIP(horizontal:Int,vertical:Int){
        self.horizontalPadding = horizontal
        self.verticalPadding = vertical
    }
    @objc public func addMarginForFloatingButton(horizontal:Int,vertical:Int){
        self.floatingHorizontalPadding = horizontal
        self.floatingVerticalPadding = vertical
    }
    
    
    internal func dismissPiPView() {
        activePIPView?.dismissPiPButton()
        activePIPView = nil
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
        self.setCurrentClassName(className: self.activescreenname)
    }
    
    internal func validateURL(url: URL) -> URL {
        let host = url.host
        if(host != nil && host!.count > 0){
            for str_url in self.whiteListedDomains {
                if (str_url.count > 0 && host!.hasSuffix(str_url)){
                    return url
                }
            }
        }
        
        return URL(string: ("\(CGConstants.default_redirect_url)?code=\(String(self.doamincode))&message=\(self.textMsg)"))!
    }
    
    @objc public func configureWhiteListedDomains(domains: [String]){
        self.whiteListedDomains = domains
        self.whiteListedDomains.append(CGConstants.default_whitelist_doamin)
    }
    
    
    @objc public func configureLightLoaderURL(locallottieLoaderURL: String){
        
        if(locallottieLoaderURL.count > 0 && URL(string: locallottieLoaderURL) != nil){
            self.lightLoaderURL = locallottieLoaderURL
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
            self.darkLoaderURL = locallottieLoaderURL
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
            self.lightEmbedLoaderURL = locallottieLoaderURL
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
            self.darkEmbedLoaderURL = locallottieLoaderURL
            let url = URL(string: locallottieLoaderURL)
            CGFileDownloader.loadFileAsync(url: url!) { [self] (path, error) in
                if (error == nil){
                    encryptUserDefaultKey(str: path ?? "", userdefaultKey: CGConstants.CUSTOMERGLU_DARK_EMBEDLOTTIE_FILE_PATH)
                }
            }
        }
    }
    
    /**
            PiP DownloadManager
     
     */
    func downloadPiPVideo(videoURL: String, pipInfo: CGData){
        if videoURL.count > 0 && URL(string: videoURL) != nil {
            self.PiPVideoURL = videoURL
            let url = URL(string: videoURL)
            CGFileDownloader.loadFileAsync(url: url!) { [weak self] (path, error) in
                DispatchQueue.main.async { [weak self] in
                    if (error == nil){
                        self?.updatePiPLocalPath(path: path ?? "")
                        
                        if pipInfo.mobile.conditions.showCount.dailyRefresh, !CGPIPHelper.shared.checkShowOnDailyRefresh(){
                          return
                        }
                        
                        self?.activePIPView = CGPictureInPictureViewController(btnInfo: pipInfo)
                        self?.setCurrentClassName(className: self?.activescreenname ?? "")
                        
                    }
                }
            }
        }
    }
    
    
    @objc public func configureDomainCodeMsg(code: Int, message: String){
        self.doamincode = code
        self.textMsg = message
    }
    
    @objc public func setCurrentClassName(className: String) {
        
        if(popuptimer != nil){
            popuptimer?.invalidate()
            popuptimer = nil
        }
        
        if self.isEntryPointEnabled {
            if !configScreens.contains(className) {
                configScreens.append(className)

            }
            sendEntryPointsIdLists()
            
            self.activescreenname = className
            
            screenNameLogicForFloatingButton(className: className)
            screenNameLogicForPIPView(className: className)
            
            showPopup(className: className)
        }
    }
    private func screenNameLogicForFloatingButton(className:String)
    {
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
    }
    
    private func screenNameLogicForPIPView(className:String)
    {
        var isHidden = true;
        var isActive  = false
        if let pipView = self.activePIPView {
           // pipView.hidePIPView(ishidden: true)
            isActive = true
            if pipView.pipInfo.mobile.container.ios.allowedActitivityList.count > 0 && pipView.pipInfo.mobile.container.ios.disallowedActitivityList.count > 0 {
                if  !(pipView.pipInfo.mobile.container.ios.disallowedActitivityList.contains(className)) {
                    isHidden = false;
                    pipView.hidePiPButton(ishidden: isHidden)
                  
                }
            } else if (pipView.pipInfo.mobile.container.ios.allowedActitivityList.count) > 0 {
                if (pipView.pipInfo.mobile.container.ios.allowedActitivityList.contains(className)) {
                    isHidden = false;
                    pipView.hidePiPButton(ishidden: isHidden)
                }
            } else if (pipView.pipInfo.mobile.container.ios.disallowedActitivityList.count) > 0 {
                if !(pipView.pipInfo.mobile.container.ios.disallowedActitivityList.contains(className)) {
                    isHidden = false;
                    pipView.hidePiPButton(ishidden: isHidden)
                }
            }
        }
        if isHidden {
            self.hidePiPView()

        }

    }
    
    
    public func sendEntryPointsIdLists()
    {
        let user_id = decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID)
        
        if self.testUsers.contains(user_id) {
            // API Call Collect ViewController Name & Post
            var eventInfo = [String: AnyHashable]()
            eventInfo[APIParameterKey.activityIdList] = configScreens
            eventInfo[APIParameterKey.bannerIds] = self.bannerIds
            eventInfo[APIParameterKey.embedIds] = self.embedIds

            APIManager.shared.entrypoints_config(queryParameters: eventInfo as NSDictionary) { result in
                switch result {
                case .success(let response):
                    if(true == self.isDebugingEnabled){
                        print(response)
                    }
                case .failure(let error):
                    self.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-setCurrentClassName", posttoserver: true)
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
                let floatButton = self.entryPointdata.filter {
                    $0._id == floatBtn._id
                }
                
                if floatButton.count > 0 && ((floatButton[0].mobile.content.count > 0) && (floatBtn.showcount?.count)! < floatButton[0].mobile.conditions.showCount.count) {
                    self.addFloatingButton(btnInfo: floatButton[0])
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                self.setCurrentClassName(className: self.activescreenname)
            })
            
        }
    }
    
    internal func addPIPViews()
    {
        let pipViews = popupDict.filter
        {
            $0.type == "PIP"
        }
        if pipViews.count != 0
        {
            for pip in pipViews {
                let pip = self.entryPointdata.filter {
                    $0._id == pip._id
                }
                
                DispatchQueue.main.async {
                    self.addPIPViewToUI(pipInfo: pip[0])
                }
            }
            
        }else{
            CGFileDownloader.deletePIPVideo()
        }
    }
    
    internal func postBannersCount() {
        
        var postInfo: [String: Any] = [:]
        
        let banners = self.entryPointdata.filter {
            $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId != nil && $0.mobile.container.bannerId.count > 0
        }
        
        if(banners.count > 0){
            for banner in banners {
                postInfo[banner.mobile.container.bannerId] = banner.mobile.content.count
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_BANNER_LOADED").rawValue), object: nil, userInfo: postInfo)
        
        let bannersforheight = self.entryPointdata.filter {
            $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId != nil && $0.mobile.container.bannerId.count > 0 && (Int($0.mobile.container.height)!) > 0 && $0.mobile.content.count > 0
        }
        if bannersforheight.count > 0 {
            self.bannersHeight = [String:Any]()
            for banner in bannersforheight {
                self.bannersHeight![banner.mobile.container.bannerId] = Int(banner.mobile.container.height)
            }
        }
        if (self.bannersHeight == nil) {
            self.bannersHeight = [String:Any]()
        }
    }
    
    internal func postEmbedsCount() {
        
        var postInfo: [String: Any] = [:]
        
        let banners = self.entryPointdata.filter {
            $0.mobile.container.type == "EMBEDDED" && $0.mobile.container.bannerId != nil && $0.mobile.container.bannerId.count > 0
        }
        
        if(banners.count > 0){
            for banner in banners {
                postInfo[banner.mobile.container.bannerId] = banner.mobile.content.count
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_EMBEDDED_LOADED").rawValue), object: nil, userInfo: postInfo)
        
        let bannersforheight = self.entryPointdata.filter {
            $0.mobile.container.type == "EMBEDDED" && $0.mobile.container.bannerId != nil && $0.mobile.container.bannerId.count > 0 /*&& (Int($0.mobile.container.height)!) > 0*/ && $0.mobile.content.count > 0
        }
        if bannersforheight.count > 0 {
            self.embedsHeight = [String:Any]()
            for banner in bannersforheight {
                //                CustomerGlu.embedsHeight![banner.mobile.container.bannerId] = Int(banner.mobile.container.height)
                self.embedsHeight![banner.mobile.container.bannerId] = Int(banner.mobile.content.first?.absoluteHeight ?? 0.0)
            }
        }
        if (self.embedsHeight == nil) {
            self.embedsHeight = [String:Any]()
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
                
                let finalPopUp = self.entryPointdata.filter {
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
            self.printlog(cglog: error.localizedDescription, isException: false, methodName: "updateShowCount", posttoserver: true)
        }
        
        guard let data = data, let jsonString2 = String(data: data, encoding: .utf8) else { return }
        encryptUserDefaultKey(str: jsonString2, userdefaultKey: CGConstants.CustomerGluPopupDict)
    }
    
    @objc private func showPopupAfterTime(sender: Timer) {
        if popuptimer != nil && !popupDisplayScreens.contains(self.activescreenname) {
            
            let userInfo = sender.userInfo as! [String:Any]
            let finalPopUp = userInfo["finalPopUp"] as! CGData
            let showCount = userInfo["popupShow"] as! PopUpModel
            
            popuptimer?.invalidate()
            popuptimer = nil
            
            let nudgeConfiguration = CGNudgeConfiguration()
            nudgeConfiguration.layout = finalPopUp.mobile.content[0].openLayout.lowercased()
            nudgeConfiguration.opacity = finalPopUp.mobile.conditions.backgroundOpacity ?? 0.5
            nudgeConfiguration.closeOnDeepLink = finalPopUp.mobile.content[0].closeOnDeepLink ?? self.auto_close_webview!
            nudgeConfiguration.relativeHeight = finalPopUp.mobile.content[0].relativeHeight ?? 0.0
            nudgeConfiguration.absoluteHeight = finalPopUp.mobile.content[0].absoluteHeight ?? 0.0
            
            self.openCampaignById(campaign_id: (finalPopUp.mobile.content[0].campaignId), nudgeConfiguration: nudgeConfiguration)
            
            self.popupDisplayScreens.append(self.activescreenname)
            updateShowCount(showCount: showCount, eventData: finalPopUp)
            callEventPublishNudge(data: finalPopUp, className: self.activescreenname, actionType: "OPEN", event_name: "ENTRY_POINT_LOAD")
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
            self.hideFloatingButtons()
            self.hidePiPView()
        }
    }
    
    internal func postAnalyticsEventForPIP(event_name:String, entry_point_id:String, entry_point_name:String,content_campaign_id:String = "",entry_point_is_expanded:String)
         {
             var eventInfo = [String: Any]()
            eventInfo[APIParameterKey.event_name] = event_name
             var entry_point_data = [String: Any]()
    
             entry_point_data[APIParameterKey.entry_point_id] = entry_point_id
             entry_point_data[APIParameterKey.entry_point_name] = entry_point_name
             entry_point_data[APIParameterKey.entry_point_is_expanded] = entry_point_is_expanded
             entry_point_data[APIParameterKey.entry_point_location] = self.activescreenname
             entry_point_data[APIParameterKey.entry_point_container] = "PIP"
             eventInfo[APIParameterKey.entry_point_data] = entry_point_data
             
             ApplicationManager.shared.sendAnalyticsEvent(eventNudge: eventInfo, campaignId: content_campaign_id, broadcastEventData: true) { success, _ in
                 if success {
                     self.printlog(cglog: String(success), isException: false, methodName: "postAnalyticsEventForEntryPoints", posttoserver: false)
                 } else {
                     self.printlog(cglog: "Fail to call sendAnalyticsEvent ", isException: false, methodName: "postAnalyticsEventForBanner", posttoserver: true)
                 }
             }
         }
    
    internal func postAnalyticsEventForEntryPoints(event_name:String, entry_point_id:String, entry_point_name:String, entry_point_container:String, content_campaign_id:String = "", action_type: String = "OPEN", open_container:String, action_c_campaign_id:String) {
        if (false == self.analyticsEvent) {
            return
        }
        
        if(("ENTRY_POINT_DISMISS" == event_name) || ("ENTRY_POINT_LOAD" == event_name) || ("ENTRY_POINT_CLICK" == event_name)){
            
            var eventInfo = [String: Any]()
            eventInfo[APIParameterKey.event_name] = event_name
            var entry_point_data = [String: Any]()
            
            entry_point_data[APIParameterKey.entry_point_id] = entry_point_id
            entry_point_data[APIParameterKey.entry_point_name] = entry_point_name
            entry_point_data[APIParameterKey.entry_point_location] = self.activescreenname
            
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
            ApplicationManager.shared.sendAnalyticsEvent(eventNudge: eventInfo, campaignId: content_campaign_id, broadcastEventData: false) { success, _ in
                if success {
                    self.printlog(cglog: String(success), isException: false, methodName: "postAnalyticsEventForEntryPoints", posttoserver: false)
                } else {
                    self.printlog(cglog: "Fail to call sendAnalyticsEvent ", isException: false, methodName: "postAnalyticsEventForBanner", posttoserver: true)
                }
            }
            
        }else{
            self.printlog(cglog: "Invalid event_name", isException: false, methodName: "postAnalyticsEventForBanner", posttoserver: true)
            return
        }
    }
    
    internal func postAnalyticsEventForNotification(userInfo: [String: AnyHashable]) {
        if (false == self.analyticsEvent) {
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
        
        ApplicationManager.shared.sendAnalyticsEvent(eventNudge: eventInfo, campaignId: campaign_id, broadcastEventData: false) { success, _ in
            if success {
                self.printlog(cglog: String(success), isException: false, methodName: "postAnalyticsEventForNotification", posttoserver: false)
            } else {
                self.printlog(cglog: "Fail to call sendAnalyticsEvent ", isException: false, methodName: "postAnalyticsEventForNotification", posttoserver: true)
            }
        }
    }
    
    internal func printlog(cglog: String = "", isException: Bool = false, methodName: String = "",posttoserver:Bool = false) {
        if(true == isDebugingEnabled){
            print("CG-LOGS: "+methodName+" : "+cglog)
        }
//
//        if(true == posttoserver){
//            ApplicationManager.shared.callCrashReport(cglog: cglog, isException: isException, methodName: methodName, user_id:  decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID))
//
//            APIManager.shared.crashReport(queryParameters: ["Method Name" : methodName, "CGLog" : cglog]) { _ in }
//        }
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
                self.printlog(cglog: error.localizedDescription, isException: false, methodName: "migrateUserDefaultKey", posttoserver: true)
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
            self.hidePiPView()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: - MQTT Setup
    private func initializeMqtt() {
        // Check if client id is in the preferences, if not there then register
        if let clientID = self.cgUserData.client, let userID = self.cgUserData.userId {
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
            let password = self.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN)
            let mqttIdentifier = decryptUserDefaultKey(userdefaultKey: CGConstants.MQTT_Identifier)

            let config = CGMqttConfig(username: username, password: password, serverHost: host, topics: [userTopic, clientTopic], port: 1883, mqttIdentifier: mqttIdentifier)
            CGMqttClientHelper.shared.setupMQTTClient(withConfig: config, delegate: self)
        } else {
            // Client ID is not available - register
            var userData = [String: AnyHashable]()
            userData["userId"] = self.cgUserData.userId ?? ""
            self.registerDevice(userdata: userData) { success in
                if success {
                    // Initialize Mqtt
                    self.initializeMqtt()
                }
            }
        }
    }
    
    func doLoadCampaignAndEntryPointCall() {
        ApplicationManager.shared.openWalletApi { success, response in
            if success {
                CustomerGlu.campaignsAvailable = response
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
    
    private func checkSSLCertificateExpiration() {
        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                let viewController = CGPreloadWKWebViewHelper()
                viewController.viewDidLoad()
            }
           
        }
        
        guard let appconfigdata = appconfigdata, let enableSslPinning = appconfigdata.enableSslPinning, enableSslPinning else { return }
        
        guard !self.decryptUserDefaultKey(userdefaultKey: CGConstants.clientSSLCertificateAsStringKey).isEmpty else {
            updateLocalCertificate()
            return
        }
    }
    
    public func updateLocalCertificate() {
        guard let appconfigdata = appconfigdata, let sslCertificateLink = appconfigdata.derCertificate else { return }
        ApplicationManager.shared.downloadCertificateFile(from: sslCertificateLink) { result in
            switch result {
            case .success:
                self.printlog(cglog: "Successfully updated the local ssl certificate", isException: false, methodName: "CustomerGlue-updateLocalCertificate", posttoserver: false)
            case .failure(let failure):
                self.printlog(cglog: "Failed to download with error: \(failure.localizedDescription)", isException: false, methodName: "CustomerGlue-updateLocalCertificate", posttoserver: false)
            }
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
                ApplicationManager.shared.openWalletApi { success, response in
                    if success {
                        CustomerGlu.campaignsAvailable = response
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
