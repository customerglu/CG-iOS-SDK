import Foundation
import SwiftUI
import UIKit

let gcmMessageIDKey = "gcm.message_id"

struct EntryPointPopUpModel: Codable {
    public var popups: [PopUpModel]?
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

public class CustomerGlu: NSObject, CustomerGluCrashDelegate {
    
    // MARK: - Global Variable
    var spinner = SpinnerView()
    var arrFloatingButton = [FloatingButtonController]()
    
    // Singleton Instance
    public static var getInstance = CustomerGlu()
    public static var sdk_disable: Bool? = false
    public static var fcm_apn = ""
    public static var analyticsEvent: Bool? = false
    let userDefaults = UserDefaults.standard
    public var apnToken = ""
    public var fcmToken = ""
    public static var defaultBannerUrl = ""
    public static var arrColor = [UIColor.black]
    public static var auto_close_webview: Bool? = true
    public static var topSafeAreaHeight = 44
    public static var bottomSafeAreaHeight = 34
    public static var topSafeAreaColor = UIColor.white
    public static var bottomSafeAreaColor = UIColor.white
    public static var entryPointdata: [CGData] = []
    public static var isDebugingEnabled = false
    public static var isEntryPointEnabled = false
    public static var activeViewController = ""
    internal var activescreenname = ""
    
        
    internal var popupDict = [PopUpModel]()
    internal var entryPointPopUpModel = EntryPointPopUpModel()
    internal var popupDisplayScreens = [String]()
    private var configScreens = [String]()
    private var popuptimer : Timer?
    
    private override init() {
        super.init()
        
        if UserDefaults.standard.object(forKey: Constants.CUSTOMERGLU_TOKEN) != nil {
            if CustomerGlu.isEntryPointEnabled {
                getEntryPointData()
            }
        }
        
        CustomerGluCrash.add(delegate: self)
        do {
            // retrieving a value for a key
            if let data = userDefaults.data(forKey: Constants.CustomerGluCrash),
               let crashItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Dictionary<String, Any> {
                ApplicationManager.callCrashReport(stackTrace: (crashItems["callStack"] as? String)!, isException: true, methodName: "CustomerGluCrash")
            }
        } catch {
            print(error)
        }
    }
    
    public func gluSDKDebuggingMode(enabled: Bool) {
        CustomerGlu.isDebugingEnabled = enabled
    }
    
    public func enableEntryPoints(enabled: Bool) {
        CustomerGlu.isEntryPointEnabled = enabled
        if CustomerGlu.isEntryPointEnabled {
            getEntryPointData()
        }
    }
    
    public func customerGluDidCatchCrash(with model: CrashModel) {
        print("\(model)")
        let dict = [
            "name": model.name!,
            "reason": model.reason!,
            "appinfo": model.appinfo!,
            "callStack": model.callStack!] as [String: Any]
        do {
            // setting a value for a key
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: true)
            userDefaults.set(encodedData, forKey: Constants.CustomerGluCrash)
            userDefaults.synchronize()
        } catch {
            print(error)
        }
    }
    
    public func disableGluSdk(disable: Bool) {
        CustomerGlu.sdk_disable = disable
    }
    
    public func isFcmApn(fcmApn: String) {
        CustomerGlu.fcm_apn = fcmApn
    }
    
    public func setDefaultBannerImage(bannerUrl: String) {
        CustomerGlu.defaultBannerUrl = bannerUrl
    }
    
    public func configureLoaderColour(color: [UIColor]) {
        CustomerGlu.arrColor = color
    }
    
    func loaderShow(withcoordinate x: CGFloat, y: CGFloat) {
        DispatchQueue.main.async { [self] in
            if let controller = topMostController() {
                controller.view.isUserInteractionEnabled = false
                spinner = SpinnerView(frame: CGRect(x: x, y: y, width: 60, height: 60))
                controller.view.addSubview(spinner)
                controller.view.bringSubviewToFront(spinner)
            }
        }
    }
    
    public func getReferralId(deepLink: URL) -> String {
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        let referrerUserId = queryItems?.filter({(item) in item.name == APIParameterKey.userId}).first?.value
        return referrerUserId ?? ""
    }
    
    public func closeWebviewOnDeeplinkEvent(close: Bool) {
        CustomerGlu.auto_close_webview = close
    }
    
    public func enableAnalyticsEvent(event: Bool) {
        CustomerGlu.analyticsEvent = event
    }
    
    func loaderHide() {
        DispatchQueue.main.async { [self] in
            if let controller = topMostController() {
                controller.view.isUserInteractionEnabled = true
                spinner.removeFromSuperview()
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
    
    public func cgUserNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        let userInfo = notification.request.content.userInfo
        
        // Change this to your preferred presentation option
        if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            if userInfo[NotificationsKey.glu_message_type] as? String == "push" {
                if UIApplication.shared.applicationState == .active {
                    completionHandler([[.alert, .badge, .sound]])
                }
            }
        }
    }
    
    public func cgapplication(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], backgroundAlpha: Double = 0.5, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            let nudge_url = userInfo[NotificationsKey.nudge_url]
            print(nudge_url as Any)
            let page_type = userInfo[NotificationsKey.page_type]
            
            if userInfo[NotificationsKey.glu_message_type] as? String == NotificationsKey.in_app {
                print(page_type as Any)
                if page_type as? String == Constants.BOTTOM_SHEET_NOTIFICATION {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.BOTTOM_SHEET_NOTIFICATION, backgroundAlpha: backgroundAlpha)
                } else if page_type as? String == Constants.BOTTOM_DEFAULT_NOTIFICATION {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.BOTTOM_DEFAULT_NOTIFICATION, backgroundAlpha: backgroundAlpha)
                } else if page_type as? String == Constants.MIDDLE_NOTIFICATIONS {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.MIDDLE_NOTIFICATIONS, backgroundAlpha: backgroundAlpha)
                } else {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: backgroundAlpha)
                }
            } else {
                print("Local Notification")
                return
            }
        } else {
        }
    }
    
    public func presentToCustomerWebViewController(nudge_url: String, page_type: String, backgroundAlpha: Double) {
        
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.urlStr = nudge_url
        customerWebViewVC.notificationHandler = true
        customerWebViewVC.alpha = backgroundAlpha
        guard let topController = UIViewController.topViewController() else {
            return
        }
        
        if page_type == Constants.BOTTOM_SHEET_NOTIFICATION {
            customerWebViewVC.isbottomsheet = true
            #if compiler(>=5.5)
            if #available(iOS 15.0, *) {
                if let sheet = customerWebViewVC.sheetPresentationController {
                    sheet.detents = [ .medium(), .large() ]
                }
            } else {
                customerWebViewVC.modalPresentationStyle = .pageSheet
            }
            #else
            customerWebViewVC.modalPresentationStyle = .pageSheet
            #endif
        } else if page_type == Constants.BOTTOM_DEFAULT_NOTIFICATION {
            customerWebViewVC.isbottomdefault = true
            customerWebViewVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customerWebViewVC.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        } else if page_type == Constants.MIDDLE_NOTIFICATIONS {
            customerWebViewVC.ismiddle = true
            customerWebViewVC.modalPresentationStyle = .overCurrentContext
        } else {
            customerWebViewVC.modalPresentationStyle = .fullScreen
        }
        topController.present(customerWebViewVC, animated: true, completion: {
            self.hideFloatingButtons()
        })
    }
    
    public func displayBackgroundNotification(remoteMessage: [String: AnyHashable]) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        let nudge_url = remoteMessage[NotificationsKey.nudge_url]
        
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.urlStr = nudge_url as? String ?? ""
        customerWebViewVC.notificationHandler = true
        customerWebViewVC.modalPresentationStyle = .fullScreen
        guard let topController = UIViewController.topViewController() else {
            return
        }
        topController.present(customerWebViewVC, animated: false, completion: {
            self.hideFloatingButtons()
        })
    }
    
    public func notificationFromCustomerGlu(remoteMessage: [String: AnyHashable]) -> Bool {
        let strType = remoteMessage[NotificationsKey.type] as? String
        if strType == NotificationsKey.CustomerGlu {
            return true
        } else {
            return false
        }
    }
    
    public func clearGluData() {
        
        dismissFloatingButtons()
        
        self.arrFloatingButton.removeAll()
        popupDict.removeAll()
        CustomerGlu.entryPointdata.removeAll()
        entryPointPopUpModel = EntryPointPopUpModel()
        
        
        userDefaults.removeObject(forKey: Constants.CUSTOMERGLU_TOKEN)
        userDefaults.removeObject(forKey: Constants.CUSTOMERGLU_USERID)
        userDefaults.removeObject(forKey: Constants.CustomerGluCrash)
        userDefaults.removeObject(forKey: Constants.CustomerGluPopupDict)
    }
    
    // MARK: - API Calls Methods
    public func registerDevice(userdata: [String: AnyHashable], loadcampaigns: Bool = false, completion: @escaping (Bool, RegistrationModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userdata["userId"] == nil {
            if CustomerGlu.sdk_disable! {
                print(CustomerGlu.sdk_disable!)
            } else {
                print("userId if required")
            }
            completion(false, nil)
            return
        }
        var userData = userdata
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            print(uuid)
            userData[APIParameterKey.deviceId] = uuid
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let writekey = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String
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
        
        APIManager.userRegister(queryParameters: userData as NSDictionary) { result in
            switch result {
                case .success(let response):
                    if response.success! {
                        self.userDefaults.set(response.data?.token, forKey: Constants.CUSTOMERGLU_TOKEN)
                        self.userDefaults.set(response.data?.user?.userId, forKey: Constants.CUSTOMERGLU_USERID)
                        self.userDefaults.synchronize()
                        if CustomerGlu.isEntryPointEnabled {
                            APIManager.getEntryPointdata(queryParameters: [:]) { result in
                                switch result {
                                    case .success(let responseGetEntry):
                                        CustomerGlu.entryPointdata.removeAll()
                                        CustomerGlu.entryPointdata = responseGetEntry.data
                                        
                                        // FLOATING Buttons
                                        let floatingButtons = CustomerGlu.entryPointdata.filter {
                                            $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP"
                                        }
                                                            
                                        self.entryPointInfoAddDelete(entryPoint: floatingButtons)
                                        self.addFloatingBtns()
                                        
                                        completion(true, response)
                                        
                                    case .failure(let error):
                                        print(error)
                                        completion(true, response)
                                }
                            }
                        } else {
                            completion(true, response)
                        }
                        
                        if loadcampaigns == true {
                            ApplicationManager.openWalletApi { success, _ in
                                if success {
                                } else {
                                }
                            }
                        }
                    } else {
                        ApplicationManager.callCrashReport(methodName: "registerDevice")
                    }
                case .failure(let error):
                    print(error)
                    ApplicationManager.callCrashReport(stackTrace: error.localizedDescription, methodName: "registerDevice")
                    completion(false, nil)
            }
        }
    }
    
    public func updateProfile(userdata: [String: AnyHashable], completion: @escaping (Bool, RegistrationModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            if CustomerGlu.sdk_disable! {
                print(CustomerGlu.sdk_disable!)
            } else {
                print("Please registered first")
            }
            completion(false, nil)
            return
        }
        
        var userData = userdata
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            print(uuid)
            userData[APIParameterKey.deviceId] = uuid
        }
        let user_id = userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID)
        if user_id == nil {
            return
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let writekey = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String
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
        
        APIManager.userRegister(queryParameters: userData as NSDictionary) { result in
            switch result {
                case .success(let response):
                    if response.success! {
                        self.userDefaults.set(response.data?.token, forKey: Constants.CUSTOMERGLU_TOKEN)
                        self.userDefaults.set(response.data?.user?.userId, forKey: Constants.CUSTOMERGLU_USERID)
                        self.userDefaults.synchronize()
                        
                        if CustomerGlu.isEntryPointEnabled {
                            APIManager.getEntryPointdata(queryParameters: [:]) { result in
                                switch result {
                                    case .success(let responseGetEntry):
                                        CustomerGlu.entryPointdata = responseGetEntry.data

                                        // FLOATING Buttons
                                        let floatingButtons = CustomerGlu.entryPointdata.filter {
                                            $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP"
                                        }
                                                            
                                        self.entryPointInfoAddDelete(entryPoint: floatingButtons)
                                        self.addFloatingBtns()
                                        
                                        completion(true, response)
                                        
                                    case .failure(let error):
                                        print(error)
                                        completion(true, response)
                                }
                            }
                        } else {
                            completion(true, response)
                        }
                    } else {
                        ApplicationManager.callCrashReport(methodName: "updateProfile")
                    }
                case .failure(let error):
                    print(error)
                    ApplicationManager.callCrashReport(stackTrace: error.localizedDescription, methodName: "updateProfile")
                    completion(false, nil)
            }
        }
    }
    
    private func getEntryPointData() {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            if CustomerGlu.sdk_disable! {
                print(CustomerGlu.sdk_disable!)
            } else {
                print("Please registered first")
            }
            return
        }
        
        APIManager.getEntryPointdata(queryParameters: [:]) { [self] result in
            switch result {
                case .success(let response):
                    CustomerGlu.entryPointdata = response.data

                    // FLOATING Buttons
                    let floatingButtons = CustomerGlu.entryPointdata.filter {
                        $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP"
                    }
                                        
                    entryPointInfoAddDelete(entryPoint: floatingButtons)
                    addFloatingBtns()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("EntryPointLoaded").rawValue), object: nil, userInfo: nil)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    private func entryPointInfoAddDelete(entryPoint: [CGData]) {
                
        if entryPoint.count > 0 {
            do {
                let popupItems = try userDefaults.getObject(forKey: Constants.CustomerGluPopupDict, castTo: EntryPointPopUpModel.self)
                popupDict = popupItems.popups!
            } catch {
                print(error.localizedDescription)
            }
            
            for dict in entryPoint {
                if popupDict.contains(where: { $0._id == dict._id }) {
                    print("1 exists in the array")
                    
                    if let index = popupDict.firstIndex(where: {$0._id == dict._id}) {
                        
                        var refreshlocal : Bool = false
                        if(dict.mobile.conditions.showCount.dailyRefresh == true && popupDict[index].showcount?.dailyRefresh == true){
                            
                            if !(Calendar.current.isDate(popupDict[index].popupdate!, equalTo: Date(), toGranularity: .day)){
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
                    print("1 does not exists in the array")
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
                    print("1 exists in the array")
                } else {
                    print("1 does not exists in the array")
                    // remove item from popupDict
                    if let index = popupDict.firstIndex(where: {$0._id == item._id}) {
                        popupDict.remove(at: index)
                    }
                }
            }
            
            entryPointPopUpModel.popups = popupDict
            
            do {
                try userDefaults.setObject(entryPointPopUpModel, forKey: Constants.CustomerGluPopupDict)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public func openWalletWithURL(url: String) {
        CustomerGlu.getInstance.presentToCustomerWebViewController(nudge_url: url, page_type: Constants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: 0.5)
    }
    
    public func openWallet() {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            if CustomerGlu.sdk_disable! {
                print(CustomerGlu.sdk_disable!)
            } else {
                print("Please registered first")
            }
            return
        }
        
        DispatchQueue.main.async {
            let openWalletVC = StoryboardType.main.instantiate(vcType: OpenWalletViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            openWalletVC.modalPresentationStyle = .fullScreen
            self.hideFloatingButtons()
            topController.present(openWalletVC, animated: true, completion: nil)
        }
    }
    
    public func loadAllCampaigns() {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            if CustomerGlu.sdk_disable! {
                print(CustomerGlu.sdk_disable!)
            } else {
                print("Please registered first")
            }
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    public func loadCampaignById(campaign_id: String) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            if CustomerGlu.sdk_disable! {
                print(CustomerGlu.sdk_disable!)
            } else {
                print("Please registered first")
            }
            return
        }
        
        DispatchQueue.main.async {
            let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            customerWebViewVC.modalPresentationStyle = .fullScreen
            customerWebViewVC.iscampignId = true
            customerWebViewVC.campaign_id = campaign_id
            self.hideFloatingButtons()
            topController.present(customerWebViewVC, animated: false, completion: nil)
        }
    }
    
    public func loadCampaignsByType(type: String) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            if CustomerGlu.sdk_disable! {
                print(CustomerGlu.sdk_disable!)
            } else {
                print("Please registered first")
            }
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.loadCampignType = APIParameterKey.type
            loadAllCampign.loadCampignValue = type
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    public func loadCampaignByStatus(status: String) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            if CustomerGlu.sdk_disable! {
                print(CustomerGlu.sdk_disable!)
            } else {
                print("Please registered first")
            }
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.loadCampignType = APIParameterKey.status
            loadAllCampign.loadCampignValue = status
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    public func loadCampaignByFilter(parameters: NSDictionary) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            if CustomerGlu.sdk_disable! {
                print(CustomerGlu.sdk_disable!)
            } else {
                print("Please registered first")
            }
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.loadByparams = parameters
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    public func sendEventData(eventName: String, eventProperties: [String: Any]) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            if CustomerGlu.sdk_disable! {
                print(CustomerGlu.sdk_disable!)
            } else {
                print("Please registered first")
            }
            return
        }
        
        ApplicationManager.sendEventData(eventName: eventName, eventProperties: ["state": "1"]) { success, addCartModel in
            if success {
                print(addCartModel as Any)
            } else {
                print("error")
            }
        }
    }
    
    public func configureSafeArea(topHeight: Int, bottomHeight: Int, topSafeAreaColor: UIColor, bottomSafeAreaColor: UIColor) {
        CustomerGlu.topSafeAreaHeight = topHeight
        CustomerGlu.bottomSafeAreaHeight = bottomHeight
        CustomerGlu.topSafeAreaColor = topSafeAreaColor
        CustomerGlu.bottomSafeAreaColor = bottomSafeAreaColor
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
    
    internal func dismissFloatingButtons() {
        for floatBtn in self.arrFloatingButton {
            floatBtn.dismissFloatingButton()
        }
    }
    
    internal func showFloatingButtons() {
        CustomerGlu.getInstance.setCurrentClassName(className: CustomerGlu.getInstance.activescreenname)
    }

    public func setCurrentClassName(className: String) {
        
        if(popuptimer != nil){
            popuptimer?.invalidate()
            popuptimer = nil
        }
        
        if CustomerGlu.isEntryPointEnabled {
            if CustomerGlu.isDebugingEnabled {
                // API Call Collect ViewController Name & Post
                
                if !configScreens.contains(className) {
                    configScreens.append(className)
                    
                    var eventInfo = [String: AnyHashable]()
                    eventInfo[APIParameterKey.activityIdList] = configScreens
                    
                    APIManager.entrypoints_config(queryParameters: eventInfo as NSDictionary) { result in
                        switch result {
                        case .success(let response):
                            print(response)
                                
                        case .failure(let error):
                            print(error)
                            ApplicationManager.callCrashReport(methodName: "publishNudge")
                        }
                    }
                }
            }
            
            CustomerGlu.getInstance.activescreenname = className

            for floatBtn in self.arrFloatingButton {
                floatBtn.hideFloatingButton(ishidden: true)
                if (floatBtn.floatInfo?.mobile.container.ios.allowedActitivityList.count)! > 0 && (floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.count)! > 0 {
                    if  !(floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.contains(className))! {
                        floatBtn.hideFloatingButton(ishidden: false)
                        callEventPublishNudge(data: floatBtn.floatInfo!, className: className, actionName: "LOADED")
                    }
                } else if (floatBtn.floatInfo?.mobile.container.ios.allowedActitivityList.count)! > 0 {
                    if (floatBtn.floatInfo?.mobile.container.ios.allowedActitivityList.contains(className))! {
                        floatBtn.hideFloatingButton(ishidden: false)
                        callEventPublishNudge(data: floatBtn.floatInfo!, className: className, actionName: "LOADED")
                    }
                } else if (floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.count)! > 0 {
                    if !(floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.contains(className))! {
                        floatBtn.hideFloatingButton(ishidden: false)
                        callEventPublishNudge(data: floatBtn.floatInfo!, className: className, actionName: "LOADED")
                    }
                }
            }
            
            showPopup(className: className)
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
                
                if ((floatButton[0].mobile.content.count > 0) && (floatBtn.showcount?.count)! < floatButton[0].mobile.conditions.showCount.count) {
                    
                        self.addFloatingButton(btnInfo: floatButton[0])
                    
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                CustomerGlu.getInstance.setCurrentClassName(className: CustomerGlu.getInstance.activescreenname)
            })

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
                
                if ((finalPopUp[0].mobile.content.count > 0) && (popupShow.showcount?.count)! < finalPopUp[0].mobile.conditions.showCount.count) {
                    
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
        
        do {
            try userDefaults.setObject(entryPointPopUpModel, forKey: Constants.CustomerGluPopupDict)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc private  func showPopupAfterTime(sender: Timer) {
        
        if popuptimer != nil && !popupDisplayScreens.contains(CustomerGlu.getInstance.activescreenname) {
            
            let userInfo = sender.userInfo as! [String:Any]
            let finalPopUp = userInfo["finalPopUp"] as! CGData
            let showCount = userInfo["popupShow"] as! PopUpModel
            
            popuptimer?.invalidate()
            popuptimer = nil
            
            if finalPopUp.mobile.content[0].openLayout == "FULL-DEFAULT" {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (finalPopUp.mobile.content[0].campaignId)!, page_type: Constants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: finalPopUp.mobile.conditions.backgroundOpacity ?? 0.5)
            } else if finalPopUp.mobile.content[0].openLayout == "BOTTOM-DEFAULT" {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (finalPopUp.mobile.content[0].campaignId)!, page_type: Constants.BOTTOM_DEFAULT_NOTIFICATION, backgroundAlpha: finalPopUp.mobile.conditions.backgroundOpacity ?? 0.5)
            }  else if finalPopUp.mobile.content[0].openLayout == "BOTTOM-SLIDER" {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (finalPopUp.mobile.content[0].campaignId)!, page_type: Constants.BOTTOM_SHEET_NOTIFICATION, backgroundAlpha: finalPopUp.mobile.conditions.backgroundOpacity ?? 0.5)
            } else {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (finalPopUp.mobile.content[0].campaignId)!, page_type: Constants.MIDDLE_NOTIFICATIONS, backgroundAlpha: finalPopUp.mobile.conditions.backgroundOpacity ?? 0.5)
            }
            
            
            self.popupDisplayScreens.append(CustomerGlu.getInstance.activescreenname)
            updateShowCount(showCount: showCount, eventData: finalPopUp)
            callEventPublishNudge(data: finalPopUp, className: CustomerGlu.getInstance.activescreenname, actionName: "OPEN")
            
        }
    }
    
    internal func callEventPublishNudge(data: CGData, className: String, actionName: String) {
        var actionType = ""
        if data.mobile.content[0].campaignId.count == 0 {
            actionType = "WALLET"
        } else if data.mobile.content[0].campaignId.contains("http://") || data.mobile.content[0].campaignId.contains("https://") {
            actionType = "CUSTOM_URL"
        } else {
            actionType = "CAMPAIGN"
        }
        
        eventPublishNudge(pageName: className, nudgeId: data.mobile.content[0]._id, actionName: actionName, actionType: actionType, openType: data.mobile.content[0].openLayout, campaignId: data.mobile.content[0].campaignId,nudgeType: data.mobile.container.type)
    }
  
    internal func openCampaignById(campaign_id: String, page_type: String, backgroundAlpha: Double) {
        
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.iscampignId = true
        customerWebViewVC.alpha = backgroundAlpha
        customerWebViewVC.campaign_id = campaign_id
        guard let topController = UIViewController.topViewController() else {
            return
        }
        
        if page_type == Constants.BOTTOM_SHEET_NOTIFICATION {
            customerWebViewVC.isbottomsheet = true
            #if compiler(>=5.5)
            if #available(iOS 15.0, *) {
                if let sheet = customerWebViewVC.sheetPresentationController {
                    sheet.detents = [ .medium(), .large() ]
                }
            } else {
                customerWebViewVC.modalPresentationStyle = .pageSheet
            }
            #else
            customerWebViewVC.modalPresentationStyle = .pageSheet
            #endif
        } else if page_type == Constants.BOTTOM_DEFAULT_NOTIFICATION {
            customerWebViewVC.isbottomdefault = true
            customerWebViewVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customerWebViewVC.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        } else if page_type == Constants.MIDDLE_NOTIFICATIONS {
            customerWebViewVC.ismiddle = true
            customerWebViewVC.modalPresentationStyle = .overCurrentContext
        } else {
            customerWebViewVC.modalPresentationStyle = .fullScreen
        }
        topController.present(customerWebViewVC, animated: true) {
            CustomerGlu.getInstance.hideFloatingButtons()
        }
    }
    
    private func eventPublishNudge(pageName: String, nudgeId: String, actionName: String, actionType: String, openType: String, campaignId: String, nudgeType:String ) {
        var eventInfo = [String: AnyHashable]()
        eventInfo[APIParameterKey.nudgeType] = nudgeType

        eventInfo[APIParameterKey.pageName] = pageName
        eventInfo[APIParameterKey.nudgeId] = nudgeId
        eventInfo[APIParameterKey.actionName] = actionName
        eventInfo[APIParameterKey.actionType] = actionType
        eventInfo[APIParameterKey.openType] = openType
        eventInfo[APIParameterKey.campaignId] = campaignId
        eventInfo[APIParameterKey.eventId] = UUID().uuidString
        eventInfo[APIParameterKey.actionPayload] = [APIParameterKey.deviceType:"iOS"]
        
        ApplicationManager.publishNudge(eventNudge: eventInfo) { success, _ in
            if success {
                print("success")
            } else {
                print("error")
            }
        }
    }
}
