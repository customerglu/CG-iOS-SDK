//
//  File.swift
//
//
//  Created by kapil on 09/11/21.
//

import Foundation
import UIKit
import WebKit
import Lottie
import Security

@objc(CustomerWebViewController)
public class CustomerWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    public static let shared: CustomerWebViewController = {
         // Instantiate the view controller from the storyboard only once
         let instance = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
         // Additional configuration if needed
         return instance
     }()
     
  
//    public static let storyboardVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
    
    @IBOutlet weak var topSafeArea: UIView!
    @IBOutlet weak var bottomSafeArea: UIView!
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    var webView = WKWebView()
    var coverview = UIView()
    public var urlStr = ""
    private var loadedurl = ""
    private var defaultwalleturl = ""
    public var auto_close_webview = CustomerGlu.auto_close_webview
    var notificationHandler = false
    var ismiddle = false
    var isbottomsheet = false
    var isbottomdefault = false
    var iscampignId = false
    public var isWebViewLoaded = false

    var documentInteractionController: UIDocumentInteractionController!
    public var alpha = 0.0
    var campaign_id = ""
    private var dismissactionglobal = CGDismissAction.UI_BUTTON
    
    
    let contentController = WKUserContentController()
    let config = WKWebViewConfiguration()
    
    var postdata = [String:Any]()
    var canpost = false
    var canopencgwebview = false
    public var nudgeConfiguration: CGNudgeConfiguration?
    private var opencgwebview_nudgeConfiguration: CGNudgeConfiguration?
    private var defaulttimer : Timer?
    var spinner = SpinnerView()
    var progressView = LottieAnimationView()
    let window = UIApplication.shared.keyWindow
    
    
    // Prevent external initialization by making the initializer private
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
   
    
    @objc public func configureSafeAreaForDevices() {
        
        let topPadding = (window?.safeAreaInsets.top)!
        let bottomPadding = (window?.safeAreaInsets.bottom)!
        
        if topPadding <= 20 || bottomPadding < 20 {
            CustomerGlu.topSafeAreaHeight = 20
            CustomerGlu.bottomSafeAreaHeight = 0
            //            CustomerGlu.topSafeAreaColor = UIColor.clear
        }
        
        topHeight.constant = CGFloat(CustomerGlu.topSafeAreaHeight)
        bottomHeight.constant = CGFloat(CustomerGlu.bottomSafeAreaHeight)
        
        if CustomerGlu.getInstance.isDarkModeEnabled(){
            topSafeArea.backgroundColor = CustomerGlu.topSafeAreaColorDark
            bottomSafeArea.backgroundColor = CustomerGlu.bottomSafeAreaColorDark
        }else {
            topSafeArea.backgroundColor = CustomerGlu.topSafeAreaColorLight
            bottomSafeArea.backgroundColor = CustomerGlu.bottomSafeAreaColorLight
        }
        
    }
    public override var shouldAutorotate: Bool{
        return false
    }
    
    deinit {
          // Clean up observers and delegates
        NotificationCenter.default.removeObserver(self)

    //      Clean up WKWebView
         webView.navigationDelegate = nil
         webView.uiDelegate = nil
         webView.stopLoading()
        if #available(iOS 14.0, *) {
            webView.configuration.userContentController.removeAllScriptMessageHandlers()
        } else {
            // Fallback on earlier versions
        }

         // Invalidate timers
         if let defaulttimer = defaulttimer {
             defaulttimer.invalidate()
             self.defaulttimer = nil
         }
      }
    
    
    func getframe()->CGRect{
        var rect = CGRect.zero
        
        let height = getconfiguredheight()
        if ismiddle {
            rect = CGRect(x: 20, y: (self.view.frame.height - height)/2, width: self.view.frame.width - 40, height: height)
            
        } else if isbottomdefault {
            rect = CGRect(x: 0, y: self.view.frame.height - height, width: self.view.frame.width, height: height)
        } else if isbottomsheet {
            rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIScreen.main.bounds.height)
        } else {
            let topPadding = (window?.safeAreaInsets.top) ?? CGSafeAreaConstants.SAFE_AREA_PADDING
            let bottomPadding = (window?.safeAreaInsets.bottom) ?? CGSafeAreaConstants.SAFE_AREA_PADDING
            topHeight.constant = CGFloat(CustomerGlu.topSafeAreaHeight == -1 ? Int(topPadding) : CustomerGlu.topSafeAreaHeight)
            bottomHeight.constant = CGFloat(CustomerGlu.bottomSafeAreaHeight == -1 ? Int(bottomPadding) : CustomerGlu.bottomSafeAreaHeight)
            rect = CGRect(x: 0, y: topHeight.constant, width: self.view.frame.width, height: self.view.frame.height - (topHeight.constant + bottomHeight.constant))
        }
        
        return rect
    }
    @objc func rotated() {
        for subview in self.view.subviews {
            if(subview == webView){
                webView.frame = getframe()
                coverview.frame = webView.frame
            }
        }
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        isWebViewLoaded = true
        
        
        setUpWebview()
        
 
    }
    
    private func setUpWebview() {
        
        // Adding observer for device rotation
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if self.nudgeConfiguration != nil {
            self.alpha = nudgeConfiguration!.opacity
            self.auto_close_webview = nudgeConfiguration!.closeOnDeepLink
            
            // Handling layout configurations
            if nudgeConfiguration!.layout == CGConstants.MIDDLE_NOTIFICATIONS || nudgeConfiguration!.layout == CGConstants.MIDDLE_NOTIFICATIONS_POPUP {
                self.ismiddle = true
                self.isbottomdefault = false
                self.isbottomsheet = false
            } else if nudgeConfiguration!.layout == CGConstants.BOTTOM_DEFAULT_NOTIFICATION || nudgeConfiguration!.layout == CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP {
                self.isbottomdefault = true
                self.ismiddle = false
                self.isbottomsheet = false
            } else if nudgeConfiguration!.layout == CGConstants.BOTTOM_SHEET_NOTIFICATION {
                self.isbottomsheet = true
                self.ismiddle = false
                self.isbottomdefault = false
            } else {
                self.ismiddle = false
                self.isbottomdefault = false
                self.isbottomsheet = false
            }
        }
        
        contentController.add(self, name: WebViewsKey.callback) //name is the key you want the app to listen to.
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true
        
        topHeight.constant = CGFloat(0.0)
        bottomHeight.constant = CGFloat(0.0)
        
        // Safely creating transparent black color
        let black = UIColor.black
        let blackTrans = black.withAlphaComponent(CGFloat(alpha))
        self.view.backgroundColor = blackTrans
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        self.configureSafeAreaForDevices()
        
        let x = self.view.frame.midX - 30
        let y = self.view.frame.midY - 30
        
        if notificationHandler {
            setupWebViewCustomFrame(url: urlStr)
        } else if iscampignId {
            campaign_id = campaign_id.trimSpace()
            print("WCampaign \(campaign_id)")
            
            if campaign_id.isEmpty || campaign_id == CGConstants.CGOPENWALLET {
                ApplicationManager.loadAllCampaignsApi(type: "", value: campaign_id, loadByparams: [:]) { [weak self] success, campaignsModel in
                    guard let self = self else { return }
                    if success {
                        self.loaderHide()
                        self.defaultwalleturl = String(campaignsModel?.defaultUrl ?? "")
                        if self.campaign_id.count == 0 {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.setupWebViewCustomFrame(url: campaignsModel?.defaultUrl ?? "")
                            }
                        } else if self.campaign_id.contains("http://") || self.campaign_id.contains("https://") {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.setupWebViewCustomFrame(url: self.campaign_id)
                            }
                        } else {
                            let campaigns: [CGCampaigns] = campaignsModel?.campaigns ?? []
                            let filteredArray = campaigns.filter { $0.campaignId.elementsEqual(self.campaign_id) || ($0.banner?.tag?.elementsEqual(self.campaign_id) ?? false) }
                            if filteredArray.count > 0 {
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    self.setupWebViewCustomFrame(url: filteredArray[0].url)
                                }
                            } else {
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    self.setupWebViewCustomFrame(url: campaignsModel?.defaultUrl ?? "")
                                }
                            }
                        }
                    } else {
                        self.loaderHide()
                        CustomerGlu.getInstance.printlog(cglog: "Fail to load loadAllCampaignsApi", isException: false, methodName: "CustomerWebViewController-viewDidLoad", posttoserver: true)
                    }
                }
            } else {
                ApplicationManager.loadSingleCampaignById(value: campaign_id) { [weak self] success, campaignsModel in
                    guard let self = self else { return }
                    if success {
                        self.loaderHide()
                        self.defaultwalleturl = String(campaignsModel?.defaultUrl ?? "")
                        if self.campaign_id.count == 0 {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.setupWebViewCustomFrame(url: campaignsModel?.defaultUrl ?? "")
                            }
                        } else if self.campaign_id.contains("http://") || self.campaign_id.contains("https://") {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.setupWebViewCustomFrame(url: self.campaign_id)
                            }
                        } else {
                            let campaigns: [CGCampaigns] = campaignsModel?.campaigns ?? []
                            let filteredArray = campaigns.filter { $0.campaignId.elementsEqual(self.campaign_id) || ($0.banner?.tag?.elementsEqual(self.campaign_id) ?? false) }
                            if filteredArray.count > 0 {
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    self.setupWebViewCustomFrame(url: filteredArray[0].url)
                                }
                            } else {
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    self.setupWebViewCustomFrame(url: campaignsModel?.defaultUrl ?? "")
                                }
                            }
                        }
                    } else {
                        self.loaderHide()
                        CustomerGlu.getInstance.printlog(cglog: "Fail to load loadSingleCampaignById", isException: false, methodName: "CustomerWebViewController-viewDidLoad", posttoserver: true)
                    }
                }
            }
            
        } else {
            webView = WKWebView(frame: getframe(), configuration: config) // Set your own frame
            loadwebView(url: urlStr, x: x, y: y)
        }
        
        webView.scrollView.contentInsetAdjustmentBehavior = .never
    }


    
    private func setupWebViewCustomFrame(url: String) {
        
        let x = self.view.frame.midX - 30
        var y = self.view.frame.midY - 30
        
        if ismiddle {
            webView = WKWebView(frame: getframe(), configuration: config)
            webView.layer.cornerRadius = 20
            webView.clipsToBounds = true
            y = webView.frame.midY - 30
        } else if isbottomdefault {
            webView = WKWebView(frame: getframe(), configuration: config)
            webView.layer.cornerRadius = 20
            webView.clipsToBounds = true
            y = webView.frame.midY - 30
        } else if isbottomsheet {
            webView = WKWebView(frame: getframe(), configuration: config)
            y = self.view.frame.midY - 30
        } else {
            topHeight.constant = CGFloat(CustomerGlu.topSafeAreaHeight)
            bottomHeight.constant = CGFloat(CustomerGlu.bottomSafeAreaHeight)
            webView = WKWebView(frame: getframe(), configuration: config)
            y = self.view.frame.midY - 30
        }
        
        loadwebView(url: url, x: x, y: y)
    }

    private func getconfiguredheight()->CGFloat {
        var finalheight = (self.view.frame.height) * (70/100)
        
        if(nudgeConfiguration != nil){
            if(nudgeConfiguration!.relativeHeight > 0){
                finalheight = (self.view.frame.height) * (nudgeConfiguration!.relativeHeight/100)
            }else if(nudgeConfiguration!.absoluteHeight > 0){
                finalheight = nudgeConfiguration!.absoluteHeight
            }
        }
        
        if (finalheight > (UIScreen.main.bounds.height - (topHeight.constant + bottomHeight.constant))){
            finalheight = (UIScreen.main.bounds.height - (topHeight.constant + bottomHeight.constant))
        }
        
        return finalheight
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if (!(ismiddle || isbottomdefault || isbottomsheet)){
            self.view.backgroundColor = CustomerGlu.getInstance.checkIsDarkMode() ? CustomerGlu.darkBackground: CustomerGlu.lightBackground
        }
        
        if (!isWebViewLoaded)
        {
            setUpWebview()
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isbottomsheet {
            CustomerGlu.getInstance.setCurrentClassName(className: CustomerGlu.getInstance.activescreenname)
        }
        if (true == self.canpost){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: self.postdata)
            self.canpost = false
            self.postdata = [String:Any]()
        }
        if (true == self.canopencgwebview){
            self.canopencgwebview = false
            self.openCGWebView()
        }
        // Clean up the web view
        isWebViewLoaded = false
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.stopLoading()
        webView.removeFromSuperview()
        if #available(iOS 14.0, *) {
            webView.configuration.userContentController.removeAllScriptMessageHandlers()
        } else {
            // Fallback on earlier versions
        }

        // Invalidate and release any timers
        if let defaulttimer = defaulttimer {
            defaulttimer.invalidate()
            self.defaulttimer = nil
        }
        self.nudgeConfiguration = CGNudgeConfiguration()
        
    }
    
    func loadwebView(url: String, x: CGFloat, y: CGFloat) {
        
        webView.navigationDelegate = self
        
        if !url.isEmpty {
            self.loadedurl = url
            
            if campaign_id != CGConstants.CGOPENWALLET, loadedurl == defaultwalleturl {
                var eventInfo = [String: Any]()
                eventInfo["campaignId"] = campaign_id
                eventInfo[APIParameterKey.messagekey] = "Invalid campaignId, opening Wallet"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CG_INVALID_CAMPAIGN_ID"), object: nil, userInfo: eventInfo)
            }
            
            webView.backgroundColor = CustomerGlu.getInstance.checkIsDarkMode() ? CustomerGlu.darkBackground : CustomerGlu.lightBackground
            
            var darkUrl = url
            if let nudgeConfiguration = nudgeConfiguration, !nudgeConfiguration.isHyperLink {
                darkUrl = url + "&darkMode=" + (CustomerGlu.getInstance.checkIsDarkMode() ? "true" : "false")
            }
            
            print("Web final url: \(darkUrl)")
            if (isbottomdefault == true) {

                webView.load(URLRequest(url: URL(string: darkUrl + "&isEmbedded=true")!))
            }
            else{
                webView.load(URLRequest(url: URL(string: darkUrl )!))
            } 
            webView.isHidden = true
            
            coverview.frame = webView.frame
            
            // Adding corner radius to coverview
            if isbottomdefault || ismiddle {
                coverview.layer.cornerRadius = 20
                coverview.layer.masksToBounds = true
            }
            
            coverview.isHidden = !webView.isHidden
            coverview.backgroundColor = webView.backgroundColor
            
            self.view.addSubview(webView)
            self.view.addSubview(coverview)
            
            // Using weak reference for timer to avoid retain cycles
            self.loaderShow(withcoordinate: getframe().midX, y: getframe().midY)
            
            defaulttimer = Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(timeoutforpageload(sender:)), userInfo: nil, repeats: false)
        } else {
            self.closePage(animated: false, dismissaction: CGDismissAction.UI_BUTTON)
        }
    }

    
    func replaceURL(originalURL: String) -> String {
        let newURL = originalURL.replacingOccurrences(of: "https://constellation.customerglu.com/", with: "http://192.168.29.184:8080/")
        return newURL
    }
    
    @objc private  func timeoutforpageload(sender: Timer) {
        hideLoaderNShowWebview()
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.closePage(animated: false,dismissaction: CGDismissAction.UI_BUTTON)
    }
    
    private func closePage(animated: Bool,dismissaction:String){
        self.dismissactionglobal = dismissaction
        self.dismiss(animated: animated) {
            CustomerGlu.getInstance.showFloatingButtons()
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // DIAGNOSTICS
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_WEBVIEW_START_PROVISIONAL, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta: [:])
    }

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard #available(iOS 12.0, *) else { return }
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return
        }
        
        guard nudgeConfiguration == nil || nudgeConfiguration?.isHyperLink == false else {
            DispatchQueue.global(qos: .background).async {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            }
            return
        }
        guard let appConfig = CustomerGlu.getInstance.appconfigdata, let enableSslPinning = appConfig.enableSslPinning, enableSslPinning else {
            DispatchQueue.global(qos: .background).async {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            }
            return
        }
        
        let policy = NSMutableArray()
        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        DispatchQueue.global(qos: .background).async {
            let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
            
            let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
            guard let localCertificateData: NSData = ApplicationManager.getLocalCertificateAsNSData() else {
                return
            }
            
            if isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data) {
                CustomerGlu.getInstance.printlog(cglog: "Certificate matched", isException: false, methodName: "CustomerWebViewController-ssl-delegate", posttoserver: false)
                ApplicationManager.saveRemoteCertificateAsNSData(remoteCertificateData)
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            } else if let savedRemoteCertificateAsNSData = ApplicationManager.getRemoteCertificateAsNSData(), savedRemoteCertificateAsNSData.isEqual(to: localCertificateData as Data) {
                CustomerGlu.getInstance.printlog(cglog: "Certificate matched", isException: false, methodName: "CustomerWebViewController-ssl-delegate", posttoserver: false)
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            } else {
                CustomerGlu.getInstance.printlog(cglog: "Certificate does not matched", isException: false, methodName: "CustomerWebViewController-ssl-delegate", posttoserver: false)
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }
    }
    
    private func executeCallBack(eventName: String, requestId: String) {
        let functionName = "sdkCallback"

        let object = """
        {
            "eventName": "\(eventName)",
            "data": {
                "requestId": "\(requestId)",
                "rewardsResponse": \(CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CGGetRewardResponse)),
                "programsResponse": \(CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CGGetProgramResponse))
            }
        }
        """
        let javascriptCode = "\(functionName)(\(object));"
        
        webView.evaluateJavaScript(javascriptCode) { (result, error) in
            if let error = error {
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "executeCallBack", posttoserver: false)
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // DIAGNOSTICS
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_WEBVIEW_DIDFINISH, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta: [:])
        
        postAnalyticsEventForWebView(isopenevent: true, dismissaction: CGDismissAction.UI_BUTTON)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // DIAGNOSTICS
        let eventData: [String: Any] = ["Error": error.localizedDescription]
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_WEBVIEW_FAILED_PROVISIONAL, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta: eventData)

        CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "didFailProvisionalNavigation", posttoserver: true)
        
        hideLoaderNShowWebview()
    }
    
    public func handleDeeplinkEvent(withEventName eventName: String, bodyData: Data, message: WKScriptMessage, diagnosticsEventData: inout [String: Any]) {
        if eventName == WebViewsKey.open_deeplink {
            let deeplink = try? JSONDecoder().decode(CGDeepLinkModel.self, from: bodyData)
            if  let deep_link = deeplink?.data?.deepLink {
                diagnosticsEventData["Data Deeplink"] = deep_link
                
                CustomerGlu.getInstance.printlog(cglog: String(deep_link), isException: false, methodName: "WebViewVC-WebViewsKey.open_deeplink", posttoserver: false)
                postdata = OtherUtils.shared.convertToDictionary(text: (message.body as? String) ?? "") ?? [String:Any]()
                self.canpost = true
                
                diagnosticsEventData["postdata"] = postdata
                diagnosticsEventData["isDeeplinkHandledByCG"] = "NA"
                
                // Post notification
                if let eventData = postdata["data"] as? [String:Any], let isDeeplinkHandledByCG = eventData["isHandledByCG"], let deeplink = eventData["deepLink"]{
                    
                    diagnosticsEventData["isDeeplinkHandledByCG"] = isDeeplinkHandledByCG
                    diagnosticsEventData["eventData deeplink"] = deeplink
                    
                    if let closeOnDeeplink =  eventData["closeOnDeeplink"] {
                        diagnosticsEventData["closeOnDeeplink"] = closeOnDeeplink
                        
                        auto_close_webview = closeOnDeeplink as? String == "true" ? true : false
                    }
                    
                    if isDeeplinkHandledByCG as! String == "true" {
                        guard let url = URL(string: "http://assets.customerglu.com/deeplink-redirect/?redirect=\(deeplink)") else { return}
                        
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                    
                    if self.auto_close_webview == true {
                        diagnosticsEventData["notificationHandler"] = notificationHandler
                        diagnosticsEventData["iscampignId"] = iscampignId
                        
                        // Posted a notification in viewDidDisappear method
                        if notificationHandler || iscampignId {
                            self.closePage(animated: true,dismissaction: CGDismissAction.CTA_REDIRECT)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                    self.canpost = false
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: self.postdata)
                    self.postdata = [String:Any]()
                }
            }
        }
    }
    
    // receive message from wkwebview
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == WebViewsKey.callback {
            guard let bodyString = message.body as? String,
                  let bodyData = bodyString.data(using: .utf8) else { fatalError() }
            
            let bodyStruct = try? JSONDecoder().decode(CGEventModel.self, from: bodyData)
            // DIAGNOSTICS
            var diagnosticsEventData: [String: Any] = ["eventName": bodyStruct?.eventName ?? "",
                                            "Name": WebViewsKey.callback]
            
            print("EventName "+(bodyStruct?.eventName ?? ""))

            if bodyStruct?.eventName == WebViewsKey.close {
                diagnosticsEventData["notificationHandler"] = notificationHandler
                diagnosticsEventData["iscampignId"] = iscampignId
                
                if notificationHandler || iscampignId {
                    self.closePage(animated: true,dismissaction: CGDismissAction.UI_BUTTON)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            if bodyStruct?.eventName == "REQUEST_API_DATA" {
                executeCallBack(eventName: "REQUEST_API_RESULT", requestId: bodyStruct?.data?.requestId ?? "")
            }
            
            if bodyStruct?.eventName == "REFRESH_API_DATA" {
                executeCallBack(eventName: "REFRESH_API_DATA_RESULT", requestId: bodyStruct?.data?.requestId ?? "")
            }
            
            // Moved this piece of code out so it can be used for ClientTesting
            handleDeeplinkEvent(withEventName: bodyStruct?.eventName ?? "", bodyData: bodyData, message: message, diagnosticsEventData: &diagnosticsEventData)
            
            if bodyStruct?.eventName == WebViewsKey.share {
                let share = try? JSONDecoder().decode(CGEventShareModel.self, from: bodyData)
                let text = share?.data?.text
                let channelName = share?.data?.channelName
                if let imageurl = share?.data?.image {
                    diagnosticsEventData["imageurl"] = imageurl
                    diagnosticsEventData["channelName"] = channelName
                    diagnosticsEventData["text"] = text ?? ""
                    
                    if imageurl == "" {
                        if channelName == "WHATSAPP" {
                            sendToWhatsapp(shareText: text!)
                        } else {
                            sendToOtherApps(shareText: text!)
                        }
                    } else {
                        if channelName == "WHATSAPP" {
                            shareImageToWhatsapp(imageString: imageurl, shareText: text ?? "")
                        } else {
                            sendImagesToOtherApp(imageString: imageurl, shareText: text ?? "")
                        }
                    }
                }
            }
            
            if bodyStruct?.eventName == WebViewsKey.updateheight {
                print("update Height")
                if (isbottomdefault == true) {
                    print("update Height bottomsheet")

                let dict = OtherUtils.shared.convertToDictionary(text: (message.body as? String)!)
                if(dict != nil && dict!.count>0 && dict?["data"] != nil){
                    let dictheight = dict?["data"] as! [String: Any]
                    if(dictheight.count > 0 && dictheight["height"] != nil){
                      var  finalHeight = (dictheight["height"])! as! Double
                        changeHeight(height: finalHeight)
                    }
                }
                                }
            }
            
            
            
            if bodyStruct?.eventName == WebViewsKey.analytics {
                
                diagnosticsEventData["analyticsEvent"] = CustomerGlu.analyticsEvent

                if (true == CustomerGlu.analyticsEvent) {
                    let dict = OtherUtils.shared.convertToDictionary(text: (message.body as? String)!)
                    if(dict != nil && dict!.count > 0 && dict?["data"] != nil) {
                        if let dict = dict, let data = dict["data"] as? [String: Any], let eventName = data["event_name"] as? String, eventName.caseInsensitiveCompare("GAME_PLAYED") == .orderedSame {
                            CustomerGlu.getInstance.activescreenname = "CGSCreen"
                            CustomerGlu.getInstance.doLoadCampaignAndEntryPointCall()
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_ANALYTICS_EVENT").rawValue), object: nil, userInfo: dict?["data"] as? [String: Any])
                    }
                }
            }
            
            if bodyStruct?.eventName == WebViewsKey.hideloader {
                hideLoaderNShowWebview()
            }
            
            if bodyStruct?.eventName == WebViewsKey.opencgwebview {
                let dict = OtherUtils.shared.convertToDictionary(text: (message.body as? String)!)
                if(dict != nil && dict!.count>0 && dict?["data"] != nil){
                    
                    let datadic = dict?["data"] as? [String : Any]
                    
                    var contenttype = "WALLET"
                    var contenturl = ""
                    var contentcampaignId = ""
                    var containertype = CGConstants.FULL_SCREEN_NOTIFICATION
                    var containerabsoluteHeight = 0.0
                    var containerrelativeHeight = 0.0
                    var hidePrevious = false
                    
                    if(datadic != nil && datadic!.count>0 && datadic!["content"] != nil){
                        
                        let contentdic = datadic!["content"] as? [String : Any]
                        if(contentdic != nil && contentdic!.count > 0){
                            
                            contenttype = contentdic!["type"] as? String ?? "WALLET"
                            contenturl = contentdic!["url"] as? String ?? ""
                            contentcampaignId = contentdic!["campaignId"] as? String ?? ""
                        }
                        
                    }
                    if(datadic != nil && datadic!.count>0 && datadic!["container"] != nil){
                        
                        let containerdic = datadic!["container"] as? [String : Any]
                        
                        containertype = containerdic!["type"] as? String ?? CGConstants.FULL_SCREEN_NOTIFICATION
                        containerabsoluteHeight = containerdic!["absoluteHeight"] as? Double ?? 0.0
                        containerrelativeHeight = containerdic!["relativeHeight"] as? Double ?? 0.0
                        
                    }
                    if(datadic != nil && datadic!.count>0 && datadic!["hidePrevious"] != nil){
                        
                        hidePrevious = datadic!["hidePrevious"] as? Bool ?? false
                        
                    }
                    
                    opencgwebview_nudgeConfiguration = CGNudgeConfiguration()
                    opencgwebview_nudgeConfiguration?.absoluteHeight = containerabsoluteHeight
                    opencgwebview_nudgeConfiguration?.relativeHeight = containerrelativeHeight
                    opencgwebview_nudgeConfiguration?.layout = containertype
                    if(contenttype == "CAMPAIGN"){
                        opencgwebview_nudgeConfiguration?.url = contentcampaignId
                    }else if(contenttype == "WALLET"){
                        opencgwebview_nudgeConfiguration?.url = CGConstants.CGOPENWALLET
                    }else{
                        opencgwebview_nudgeConfiguration?.url = contenturl
                    }
                    
                    diagnosticsEventData["contenttype"] = contenttype
                    diagnosticsEventData["contenturl"] = contenturl
                    diagnosticsEventData["contentcampaignId"] = contentcampaignId
                    diagnosticsEventData["containertype"] = containertype
                    diagnosticsEventData["containerabsoluteHeight"] = containerabsoluteHeight
                    diagnosticsEventData["containerrelativeHeight"] = containerrelativeHeight
                    diagnosticsEventData["hidePrevious"] = hidePrevious
                    
                    if(true == hidePrevious){
                        canopencgwebview = true
                        if notificationHandler || iscampignId {
                            self.closePage(animated: true,dismissaction: CGDismissAction.CTA_REDIRECT)
                        }else{
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else{
                        canopencgwebview = false
                        openCGWebView()
                    }
                    
                }
            }
            
            // DIAGNOSTICS
            CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_WEBVIEW_RECEIVE_MESSAGE_FROM_WEBVIEW, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta: diagnosticsEventData)
        }
    }
    
    func changeHeight(height: Double) {
        // Calculate the screen height limit (screen height - 100)
        let maxAllowedHeight = self.view.frame.height - 100
        var adjustedHeight = height
        
        // If the provided height exceeds the limit, set it to the max allowed height
        if height > Double(maxAllowedHeight) {
            adjustedHeight = Double(maxAllowedHeight)
        }
        
        // Update the UI on the main thread
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                // Adjust the frame of the web view and cover view for smooth transition
                var newFrame = self.webView.frame
                newFrame.size.height = CGFloat(adjustedHeight + 20)
                newFrame.origin.y = self.view.frame.height - CGFloat(adjustedHeight)
                self.webView.frame = newFrame
                self.coverview.frame = newFrame
            })
        }
    }

    
    private func openCGWebView(){
        if(opencgwebview_nudgeConfiguration != nil){
            
            if(CGConstants.CGOPENWALLET == opencgwebview_nudgeConfiguration?.url){
                CustomerGlu.getInstance.loadCampaignById(campaign_id: CGConstants.CGOPENWALLET, nudgeConfiguration: opencgwebview_nudgeConfiguration)
            }else{
                CustomerGlu.getInstance.loadCampaignById(campaign_id: opencgwebview_nudgeConfiguration?.url ?? "", nudgeConfiguration: opencgwebview_nudgeConfiguration)
            }
            
        }
    }
    private func hideLoaderNShowWebview(){
        
        if(defaulttimer != nil){
            defaulttimer?.invalidate()
            defaulttimer = nil
        }
        
        self.loaderHide()
        webView.isHidden = false
        coverview.isHidden = !webView.isHidden
    }
    private func sendToOtherApps(shareText: String) {
        // set up activity view controller
        let textToShare = [ shareText ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func sendToWhatsapp(shareText: String) {
        let urlWhats = "whatsapp://send?text=\(shareText)"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    UIApplication.shared.open(whatsappURL)
                } else {
                    CustomerGlu.getInstance.printlog(cglog: "Can't open whatsapp", isException: false, methodName: "sendToWhatsapp", posttoserver: true)
                }
            }
        }
    }
    
    private func sendImagesToOtherApp(imageString: String, shareText: String) {
        // Set your image's URL into here
        let url = URL(string: imageString)!
        data(from: url) { data, response, error in
            if(true == CustomerGlu.isDebugingEnabled){
                print(response as Any)
            }
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async { [weak self] in
                if let image = UIImage(data: data) {
                    // set up activity view controller
                    let imageToShare = [shareText, image] as [Any]
                    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        activityViewController.popoverPresentationController?.sourceView = self!.view
                        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                    }
                    self!.present(activityViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func shareImageToWhatsapp(imageString: String, shareText: String) {
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    // Set your image's URL into here
                    let url = URL(string: imageString)!
                    data(from: url) { data, response, error in
                        if(true == CustomerGlu.isDebugingEnabled){
                            print(response as Any)
                        }
                        guard let data = data, error == nil else { return }
                        DispatchQueue.main.async { [weak self] in
                            let image = UIImage(data: data)
                            if let imageData = image!.jpegData(compressionQuality: 1.0) {
                                let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                                do {
                                    try imageData.write(to: tempFile, options: .atomic)
                                    self!.documentInteractionController = UIDocumentInteractionController(url: tempFile)
                                    self!.documentInteractionController.uti = "net.whatsapp.image"
                                    self?.documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: self!.view, animated: true)
                                } catch {
                                    CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "shareImageToWhatsapp", posttoserver: true)
                                }
                            }
                        }
                    }
                } else {
                    CustomerGlu.getInstance.printlog(cglog: "Can't open whatsapp", isException: false, methodName: "shareImageToWhatsapp", posttoserver: true)
                }
            }
        }
    }
    
    func data(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func postAnalyticsEventForWebView(isopenevent:Bool,dismissaction:String) {
        if (false == CustomerGlu.analyticsEvent) {
            return
        }
        var eventInfo = [String: Any]()
        
        if(isopenevent){
            eventInfo[APIParameterKey.event_name] = "WEBVIEW_LOAD"
        }else{
            eventInfo[APIParameterKey.event_name] = "WEBVIEW_DISMISS"
            eventInfo[APIParameterKey.dismiss_trigger] = dismissaction
        }
        
        var webview_content = [String: String]()
        webview_content[APIParameterKey.webview_url] = loadedurl
        
        var webview_layout = ""
        var absolute_height = String(0.0)
        var relative_height = String(70.0)
        if(nudgeConfiguration != nil){
            webview_layout = nudgeConfiguration!.layout
            if(nudgeConfiguration!.absoluteHeight > 0 && nudgeConfiguration!.relativeHeight > 0){
                absolute_height = String(nudgeConfiguration!.absoluteHeight)
                relative_height = String(nudgeConfiguration!.relativeHeight)
            }else if(nudgeConfiguration!.relativeHeight > 0){
                relative_height = String(nudgeConfiguration!.relativeHeight)
            }else if(nudgeConfiguration!.absoluteHeight > 0){
                absolute_height = String(nudgeConfiguration!.absoluteHeight)
                relative_height = String(0.0)
            }
            
            if(nudgeConfiguration!.layout == CGConstants.FULL_SCREEN_NOTIFICATION || nudgeConfiguration!.relativeHeight > 100){
                relative_height = String(100.0)
            }
            
        }else{
            if ismiddle {
                webview_layout = CGConstants.MIDDLE_NOTIFICATIONS_POPUP
            } else if isbottomdefault {
                webview_layout = CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP
            } else if isbottomsheet {
                webview_layout = CGConstants.BOTTOM_SHEET_NOTIFICATION
            } else {
                webview_layout = CGConstants.FULL_SCREEN_NOTIFICATION
                relative_height = String(100.0)
            }
        }
        webview_content[APIParameterKey.webview_layout] = webview_layout
        webview_content[APIParameterKey.absolute_height] = absolute_height
        webview_content[APIParameterKey.relative_height] = relative_height
        eventInfo[APIParameterKey.webview_content] = webview_content
        
        ApplicationManager.sendAnalyticsEvent(eventNudge: eventInfo, campaignId: campaign_id, broadcastEventData: false) { success, _ in
            if success {
                CustomerGlu.getInstance.printlog(cglog: String(success), isException: false, methodName: "WebView-postAnalyticsEventForWebView", posttoserver: false)
            } else {
                CustomerGlu.getInstance.printlog(cglog: "Fail to call sendAnalyticsEvent", isException: false, methodName: "WebView-postAnalyticsEventForWebView", posttoserver: true)
            }
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_ANALYTICS_EVENT").rawValue), object: nil, userInfo: eventInfo)
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            // TODO: Do your stuff here.
            postAnalyticsEventForWebView(isopenevent: false, dismissaction: dismissactionglobal)
        }
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //        checkIsDarkMode()
    }
    
    private func loaderShow(withcoordinate x: CGFloat, y: CGFloat) {
        if let nudgeConfiguration = nudgeConfiguration, nudgeConfiguration.isHyperLink {
            return
        }
        
        DispatchQueue.main.async { [self] in
                self.view.isUserInteractionEnabled = false
                
                var path_key = ""
                if CustomerGlu.getInstance.checkIsDarkMode() {
                    path_key = CGConstants.CUSTOMERGLU_DARK_LOTTIE_FILE_PATH
                } else {
                    path_key = CGConstants.CUSTOMERGLU_LIGHT_LOTTIE_FILE_PATH
                }
                let path = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: path_key)
                
                progressView.removeFromSuperview()
                spinner.removeFromSuperview()
                
                if path.count > 0 && URL(string: path) != nil && path.hasSuffix(".json") {
//                    progressView = LottieAnimationView(url: URL(string: "https://assets.customerglu.com/sdk-assets/embed-loader-skeleton-light.json") ?? "", closure: {_ in } )
                    print("Lottie Path: "+path)
                    progressView = LottieAnimationView(filePath: CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: path_key))
//                    let url = URL(string: "https://assets.customerglu.com/sdk-assets/embed-loader-skeleton-light.json")
//                    progressView = LottieAnimationView(url: url!) { _ in
//                               // Handle the completion of loading the Lottie animation here, if needed
//                           }
                    let size = (UIScreen.main.bounds.width <= UIScreen.main.bounds.height) ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
                    
                    progressView.frame = CGRect(x: x-(size/2), y: y-(size/2), width: size, height: size)
                    progressView.contentMode = .scaleAspectFit
                    progressView.loopMode = .loop
                    progressView.play()
                    self.view.addSubview(progressView)
                    self.view.bringSubviewToFront(progressView)
                    print("Lottie frame: \(progressView.frame)")
                    print("Lottie superview: \(String(describing: progressView.superview))")
                } else {
                    spinner = SpinnerView(frame: CGRect(x: x-30, y: y-30, width: 60, height: 60))
                    self.view.addSubview(spinner)
                    self.view.bringSubviewToFront(spinner)
                }
            }
        
    }
    
    private func loaderHide() {
        if let nudgeConfiguration = nudgeConfiguration, nudgeConfiguration.isHyperLink{
            return
        }
        
        DispatchQueue.main.async { [self] in
                self.view.isUserInteractionEnabled = true
                spinner.removeFromSuperview()
                progressView.removeFromSuperview()
        }
        
    }
}
