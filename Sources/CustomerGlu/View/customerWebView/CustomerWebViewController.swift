//
//  File.swift
//
//
//  Created by kapil on 09/11/21.
//

import Foundation
import UIKit
import WebKit

protocol CustomerGluWebViewDelegate: AnyObject {
    func closeClicked(_ success: Bool)
}

public class CustomerWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
        
    public static let storyboardVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
    
    @IBOutlet weak var topSafeArea: UIView!
    @IBOutlet weak var bottomSafeArea: UIView!
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    var webView = WKWebView()
    public var urlStr = ""
    var openWallet = false
    var notificationHandler = false
    var ismiddle = false
    var isbottomsheet = false
    var isbottomdefault = false
    var iscampignId = false
    weak var delegate: CustomerGluWebViewDelegate?
    var documentInteractionController: UIDocumentInteractionController!
    public var alpha = 0.0
    var campaign_id = ""
    
    public func configureSafeAreaForDevices(){
        
        let window = UIApplication.shared.keyWindow
        let topPadding = (window?.safeAreaInsets.top)!
        let bottomPadding = (window?.safeAreaInsets.bottom)!
        
        if(topPadding <= 20 || bottomPadding < 20){
            CustomerGlu.topSafeAreaHeight = 20
            CustomerGlu.bottomSafeAreaHeight = 0
            CustomerGlu.topSafeAreaColor = UIColor.clear
        }
        
        topHeight.constant = CGFloat(CustomerGlu.topSafeAreaHeight)
        bottomHeight.constant = CGFloat(CustomerGlu.bottomSafeAreaHeight)
        topSafeArea.backgroundColor = CustomerGlu.topSafeAreaColor
        bottomSafeArea.backgroundColor = CustomerGlu.bottomSafeAreaColor
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let contentController = WKUserContentController()
        contentController.add(self, name: WebViewsKey.callback) //name is the key you want the app to listen to.
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
    
        let x = self.view.frame.midX - 30
        var y = self.view.frame.midY - 30


        self.configureSafeAreaForDevices()
        
        if notificationHandler {
            topHeight.constant = CGFloat(0.0)
            bottomHeight.constant = CGFloat(0.0)
            let black = UIColor.black
            let blackTrans = UIColor.withAlphaComponent(black)(CGFloat(alpha))
            self.view.backgroundColor = blackTrans
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            self.view.addGestureRecognizer(tap)
            
            let height = (self.view.frame.height) / 1.4
            if ismiddle {
                webView = WKWebView(frame: CGRect(x: 20, y: (self.view.frame.height - height)/2, width: self.view.frame.width - 40, height: height), configuration: config) //set your own frame
                webView.layer.cornerRadius = 20
                webView.clipsToBounds = true
                y = webView.frame.midY - 30
            } else if isbottomdefault {
                webView = WKWebView(frame: CGRect(x: 0, y: self.view.frame.height - height, width: self.view.frame.width, height: height), configuration: config) //set your own frame
                webView.layer.cornerRadius = 20
                webView.clipsToBounds = true
                y = webView.frame.midY - 30
            } else if isbottomsheet {
                webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIScreen.main.bounds.height), configuration: config) //set your own frame
                y = self.view.frame.midY - 30
            } else {
                topHeight.constant = CGFloat(CustomerGlu.topSafeAreaHeight)
                bottomHeight.constant = CGFloat(CustomerGlu.bottomSafeAreaHeight)
                webView = WKWebView(frame: CGRect(x: 0, y: topHeight.constant, width: self.view.frame.width, height: self.view.frame.height - (topHeight.constant + bottomHeight.constant)), configuration: config) //set your own frame
                y = self.view.frame.midY - 30
            }
            setwebView(url: urlStr, x: x, y: y)
        } else if iscampignId {
            CustomerGlu.getInstance.loaderShow(withcoordinate: x, y: y)
            
            campaign_id = campaign_id.trimSpace()
            
            ApplicationManager.loadAllCampaignsApi(type: "", value: campaign_id, loadByparams: [:]) { success, campaignsModel in
                if success {
                    CustomerGlu.getInstance.loaderHide()
                    let campaigns: [Campaigns] = (campaignsModel?.campaigns)!
                    let filteredArray = campaigns.filter({($0.campaignId.elementsEqual(self.campaign_id))})
                    if filteredArray.count > 0 {
                        DispatchQueue.main.async {
                            self.webView = WKWebView(frame: CGRect(x: 0, y: self.topHeight.constant, width: self.view.frame.width, height: self.view.frame.height - (self.topHeight.constant + self.bottomHeight.constant)), configuration: config) //set your own frame
                            self.setwebView(url: filteredArray[0].url, x: x, y: y)
                        }
                    } else {
                        let userDefaults = UserDefaults.standard
                        do {
                            let campaignsModel = try userDefaults.getObject(forKey: Constants.WalletRewardData, castTo: CampaignsModel.self)
                            DispatchQueue.main.async { [self] in // Make sure you're on the main thread here
                                self.webView = WKWebView(frame: CGRect(x: 0, y: self.topHeight.constant, width: self.view.frame.width, height: self.view.frame.height - (self.topHeight.constant + self.bottomHeight.constant)), configuration: config) //set your own frame
                                self.setwebView(url: campaignsModel.defaultUrl, x: x, y: y)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    CustomerGlu.getInstance.loaderHide()
                    print("error")
                }
            }
        } else {
            webView = WKWebView(frame: CGRect(x: 0, y: topHeight.constant, width: self.view.frame.width, height: self.view.frame.height - (topHeight.constant + bottomHeight.constant)), configuration: config) //set your own frame
            setwebView(url: urlStr, x: x, y: y)
        }
        webView.scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
    }
        
    func setwebView(url: String, x: CGFloat, y: CGFloat) {
        webView.navigationDelegate = self
        if url != "" || !url.isEmpty {
            webView.load(URLRequest(url: URL(string: url)!))
        } else {
            self.dismiss(animated: false, completion: nil)
        }
        self.view.addSubview(webView)
        CustomerGlu.getInstance.loaderShow(withcoordinate: x, y: y)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: false, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Started to load")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished loading")
        CustomerGlu.getInstance.loaderHide()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        CustomerGlu.getInstance.loaderHide()
    }
    
    // receive message from wkwebview
    public func userContentController(
        _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
    ) {
        print(message.name)
        print(message)
        print("Body message", message.body)
        if message.name == WebViewsKey.callback {
            guard let bodyString = message.body as? String,
                  let bodyData = bodyString.data(using: .utf8) else { fatalError() }
            
            let bodyStruct = try? JSONDecoder().decode(EventModel.self, from: bodyData)
            
            if bodyStruct?.eventName == WebViewsKey.close {
                if openWallet {
                    delegate?.closeClicked(true)
                } else if notificationHandler || iscampignId {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            if bodyStruct?.eventName == WebViewsKey.open_deeplink {
                let deeplink = try? JSONDecoder().decode(DeepLinkModel.self, from: bodyData)
                if  let deep_link = deeplink?.data?.deepLink {
                    print("link", deep_link)
                    let dict = OtherUtils.shared.convertToDictionary(text: (message.body as? String)!)
                    // Post notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: dict?["data"] as? [String: Any])
                    if CustomerGlu.auto_close_webview == true {
                        delegate?.closeClicked(true)
                    }
                }
            }
            
            if bodyStruct?.eventName == WebViewsKey.share {
                let share = try? JSONDecoder().decode(EventShareModel.self, from: bodyData)
                let text = share?.data?.text
                let channelName = share?.data?.channelName
                if let imageurl = share?.data?.image {
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
        }
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
                    ApplicationManager.callCrashReport(stackTrace: "Can't open whatsapp", methodName: "sendToWhatsapp")
                    print("Can't open whatsapp")
                }
            }
        }
    }
    
    private func sendImagesToOtherApp(imageString: String, shareText: String) {
        // Set your image's URL into here
        let url = URL(string: imageString)!
        data(from: url) { data, response, error in
            print(response as Any)
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
                        print(response as Any)
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
                                    print(error)
                                }
                            }
                        }
                    }
                } else {
                    ApplicationManager.callCrashReport(stackTrace: "Can't open whatsapp", methodName: "shareImageToWhatsapp")
                    print("Can't open whatsapp")
                }
            }
        }
    }
    
    func data(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}