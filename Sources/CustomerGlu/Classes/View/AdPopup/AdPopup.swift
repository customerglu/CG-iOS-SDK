// Updated AdPopupViewController.swift with proper safe area handling for FULL-DEFAULT

import UIKit
import Lottie
import SVGKit
import Foundation
import AVFoundation

class AdPopupViewController: UIViewController {
    
    private var entryPointId: String
    private var campaignId: String?
    private var entryPointsData: CGData?
    private var dismissactionglobal = CGDismissAction.UI_BUTTON
    private var cardHeight: CGFloat?
    private var cardBottomMargins: Int = -32
    private let mainView = UIView()
    private let cardView = UIView()
    private let cardBackgroundImageView = UIImageView()
    private let imageView = UIImageView()
    private let primaryCTAButton = UIButton(type: .system)
    private let secondaryCTAButton = UIButton(type: .system)
    private let closeIconView = UIImageView()
    private var videoPlayer = CGVideoPlayer()
    let topSafeAreaView = UIView()
    let bottomSafeAreaView = UIView()
    
    init(entryPointId: String) {
        self.entryPointId = entryPointId
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomerGlu.getInstance.setCurrentClassName(className: "CGSCreen")
        setupEntryPoint()
        setupViews()
        setupLayout()
        applyData()
        registerDismissTap()
        postAnalyticsEvent(event_name: "ENTRY_POINT_LOAD")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        let topInset = view.safeAreaInsets.top
        let bottomInset = view.safeAreaInsets.bottom
        
        if isFullLayout() {
            topSafeAreaView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topInset)
            bottomSafeAreaView.frame = CGRect(x: 0, y: view.bounds.height - bottomInset, width: view.bounds.width, height: bottomInset)
        } else {
            bottomSafeAreaView.frame = CGRect(x: 0, y: view.bounds.height - bottomInset, width: view.bounds.width, height: bottomInset)
        }
        
        
    }
    
    private func setupEntryPoint() {
        
        var entryPointsDataArray  = CustomerGlu.entryPointdata
        
        if  !entryPointsDataArray.isEmpty {
                // Iterate through all entry points to find the matching ID
                for data in entryPointsDataArray {
                    if let dataId = data._id, dataId == self.entryPointId {
                        entryPointsData = data
                        break
                    }
                }
            }

        
    }
    
    private func isFullLayout() -> Bool {
        return entryPointsData?.mobile.content?.first?.openLayout == "FULL-DEFAULT"
    }
    
    private func setupViews() {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            view.frame = window.bounds
        }
        
        view.addSubview(mainView)
        let isDark = CustomerGlu.getInstance.isDarkModeEnabled()
        
        if isFullLayout() {
            // Add and style top safe area
            view.addSubview(topSafeAreaView)
            view.addSubview(bottomSafeAreaView)
            
            topSafeAreaView.backgroundColor = isDark ? CustomerGlu.topSafeAreaColorDark : CustomerGlu.topSafeAreaColorLight
            bottomSafeAreaView.backgroundColor = isDark ? CustomerGlu.bottomSafeAreaColorDark : CustomerGlu.bottomSafeAreaColorLight
            
            // Apply safe area heights immediately
            let topInset = view.safeAreaInsets.top
            let bottomInset = view.safeAreaInsets.bottom
            topSafeAreaView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topInset)
            bottomSafeAreaView.frame = CGRect(x: 0, y: view.bounds.height - bottomInset, width: view.bounds.width, height: bottomInset)
            
        } else {
            view.addSubview(bottomSafeAreaView)
            
            bottomSafeAreaView.backgroundColor = isDark ? CustomerGlu.bottomSafeAreaColorDark : CustomerGlu.bottomSafeAreaColorLight
            
            let bottomInset = view.safeAreaInsets.bottom
            bottomSafeAreaView.frame = CGRect(x: 0, y: view.bounds.height - bottomInset, width: view.bounds.width, height: bottomInset)
            
        }
        
        if let btn = entryPointsData?.mobile.content?.first?.secondaryCta?.button, btn.showButton ?? false  {
            secondaryCTAButton.isHidden = false;
        }else{
            secondaryCTAButton.isHidden = true;

        }
        
        mainView.addSubview(cardView)
        cardView.addSubview(cardBackgroundImageView)
        cardView.addSubview(imageView)
        cardView.addSubview(primaryCTAButton)
        cardView.addSubview(secondaryCTAButton)
        cardView.addSubview(closeIconView)
        cardView.addSubview(videoPlayer)
        view.sendSubviewToBack(mainView)
        cardView.bringSubviewToFront(primaryCTAButton)
        cardView.bringSubviewToFront(secondaryCTAButton)
        primaryCTAButton.isUserInteractionEnabled = true
        cardView.isUserInteractionEnabled = true
        mainView.isUserInteractionEnabled = true

        
        if !isFullLayout() {
            cardView.layer.cornerRadius = 16
            cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        
        closeIconView.contentMode = .scaleAspectFit
        closeIconView.tintColor = .gray
        closeIconView.isUserInteractionEnabled = true
        cardView.bringSubviewToFront(closeIconView)
        closeIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        primaryCTAButton.addTarget(self, action: #selector(primaryCTAClicked), for: .touchUpInside)
        secondaryCTAButton.addTarget(self, action: #selector(secondaryCTAClicked), for: .touchUpInside)
        
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CustomerGlu.getInstance.setCurrentClassName(className: CustomerGlu.getInstance.activescreenname)
        
    }
    
    @objc private func primaryCTAClicked() {
        postAnalyticsEvent(event_name: CGConstants.ENTRY_POINT_CLICK)
        var dict = entryPointsData?.mobile.content[0]
        guard let actionData = dict?.primaryCta, let type = actionData.type else { return }
        if type == WebViewsKey.open_deeplink {
            
            //Incase of Handled by CG is true
            if actionData.isHandledBySDK == true {
                guard let url = URL(string: "http://assets.customerglu.com/deeplink-redirect/?redirect=\(actionData.url)" as! String) else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            // Converted data for NSNotification.
            var data: [String: Any]
            var postdata: [String:Any] = ["eventName":WebViewsKey.open_deeplink,
                                          "data": ["deepLink": actionData.url]]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: postdata)
            
        }
        else if type == WebViewsKey.open_weblink{
            // Hyperlink logic
            let nudgeConfiguration = CGNudgeConfiguration()
            nudgeConfiguration.layout = dict?.primaryCta?.openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
            nudgeConfiguration.opacity = entryPointsData?.mobile.conditions?.backgroundOpacity ?? 0.5
            nudgeConfiguration.closeOnDeepLink = dict?.closeOnDeepLink ?? CustomerGlu.auto_close_webview!
            nudgeConfiguration.relativeHeight = dict?.primaryCta?.relativeHeight ?? 0.0
            nudgeConfiguration.absoluteHeight = dict?.primaryCta?.absoluteHeight ?? 0.0
            nudgeConfiguration.isHyperLink = true
            
            CustomerGlu.getInstance.openURLWithNudgeConfig(url: actionData.url, nudgeConfiguration: nudgeConfiguration)
        }
        else if type == WebViewsKey.share{
            shareAction(text: dict?.primaryCta?.shareText, image: dict?.primaryCta?.shareImage)
        }
        else if type == WebViewsKey.close{
            handleDismiss()
        }
        else {
            //Incase of any data is missing
            // Check to open wallet or not in fallback case
            guard CustomerGlu.getInstance.checkToOpenWalletOrNot(withCampaignID: dict?.campaignId ?? "") else {
                return
            }
            
            //Load Campaign Id from the payload
            if let campaignId = dict?.campaignId {
                let nudgeConfiguration = CGNudgeConfiguration()
                nudgeConfiguration.layout = dict?.primaryCta?.openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
                nudgeConfiguration.opacity = entryPointsData?.mobile.conditions?.backgroundOpacity ?? 0.5
                nudgeConfiguration.closeOnDeepLink = dict?.closeOnDeepLink ?? CustomerGlu.auto_close_webview!
                nudgeConfiguration.relativeHeight = dict?.primaryCta?.relativeHeight ?? 0.0
                nudgeConfiguration.absoluteHeight = dict?.primaryCta?.absoluteHeight ?? 0.0
                CustomerGlu.getInstance.openCampaignById(campaign_id: dict?.campaignId ?? "", nudgeConfiguration: nudgeConfiguration)
            }else {
                // If Campaign id is unavailable open wallet condition.
                CustomerGlu.getInstance.openWallet()
            }
        }
        
        if dict?.primaryCta?.type == WebViewsKey.open_deeplink{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func shareAction(text: String?, image: String?) {
        guard let text = text else { return }
        
        var sharingText = text
        if !sharingText.isEmpty {
            sharingText = sharingText.replacingOccurrences(of: "\\n", with: "\n")
        }
        
        if let image = image, image.isEmpty {
            // If image exists, send to other apps (custom logic)
            sendToOtherApps(shareText: sharingText)
        } else {
            do {
                let dataDict: [String: String] = [
                    "text": sharingText,
                    "image": image ?? ""
                ]
                let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: [])
                let jsonString = String(data: jsonData, encoding: .utf8) ?? sharingText
                
                let userInfo: [String: Any] = ["data": jsonString]
                NotificationCenter.default.post(name: NSNotification.Name("CUSTOMERGLU_SHARE_EVENT"), object: nil, userInfo: userInfo)
                
            } catch {
                print("Error serializing share data: \(error)")
            }
        }
    }
    
    func loadSVG(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for SVG: \(urlString)")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let svgImage = SVGKImage(data: data) {
                
                DispatchQueue.main.async {
                    // Remove existing subviews
                    imageView.subviews.forEach { $0.removeFromSuperview() }
                    
                    // Create SVGKFastImageView with the loaded SVG image - properly unwrapped
                    if let svgView = SVGKFastImageView(svgkImage: svgImage) {
                        // Add the view first, then set the frame
                        imageView.addSubview(svgView)
                        
                        // Set the frame to match the parent imageView
                        svgView.frame = imageView.bounds
                        svgView.contentMode = .scaleAspectFit
                        svgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    } else {
                        print("❌ Failed to create SVGKFastImageView for: \(urlString)")
                    }
                }
            } else {
                print("❌ Failed to load SVG data from URL: \(urlString)")
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
    
    @objc private func secondaryCTAClicked() {
        postAnalyticsEvent(event_name: CGConstants.ENTRY_POINT_CLICK)
        
        var dict = entryPointsData?.mobile.content[0]
        guard let actionData = dict?.secondaryCta, let type = actionData.type else { return }
        if type == WebViewsKey.open_deeplink {
            
            //Incase of Handled by CG is true
            if actionData.isHandledBySDK == true {
                guard let url = URL(string: "http://assets.customerglu.com/deeplink-redirect/?redirect=\(actionData.url)" as! String) else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            // Converted data for NSNotification.
            var data: [String: Any]
            var postdata: [String:Any] = ["eventName":WebViewsKey.open_deeplink,
                                          "data": ["deepLink": actionData.url]]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: postdata)
            
        }else if type == WebViewsKey.open_weblink{
            // Hyperlink logic
            let nudgeConfiguration = CGNudgeConfiguration()
            nudgeConfiguration.layout = dict?.secondaryCta?.openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
            nudgeConfiguration.opacity = entryPointsData?.mobile.conditions?.backgroundOpacity ?? 0.5
            nudgeConfiguration.closeOnDeepLink = dict?.closeOnDeepLink ?? CustomerGlu.auto_close_webview!
            nudgeConfiguration.relativeHeight = dict?.secondaryCta?.relativeHeight ?? 0.0
            nudgeConfiguration.absoluteHeight = dict?.secondaryCta?.absoluteHeight ?? 0.0
            nudgeConfiguration.isHyperLink = true
            
            CustomerGlu.getInstance.openURLWithNudgeConfig(url: actionData.url, nudgeConfiguration: nudgeConfiguration)
        }
        else if type == WebViewsKey.share{
            shareAction(text: dict?.secondaryCta?.shareText, image: dict?.secondaryCta?.shareImage)
        }
        else if type == WebViewsKey.close{
            handleDismiss()
            
        }
        else {
            //Incase of any data is missing
            // Check to open wallet or not in fallback case
            guard CustomerGlu.getInstance.checkToOpenWalletOrNot(withCampaignID: dict?.campaignId ?? "") else {
                return
            }
            
            //Load Campaign Id from the payload
            if let campaignId = dict?.campaignId {
                let nudgeConfiguration = CGNudgeConfiguration()
                nudgeConfiguration.layout = dict?.secondaryCta?.openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
                nudgeConfiguration.opacity = entryPointsData?.mobile.conditions?.backgroundOpacity ?? 0.5
                nudgeConfiguration.closeOnDeepLink = dict?.closeOnDeepLink ?? CustomerGlu.auto_close_webview!
                nudgeConfiguration.relativeHeight = dict?.secondaryCta?.relativeHeight ?? 0.0
                nudgeConfiguration.absoluteHeight = dict?.secondaryCta?.absoluteHeight ?? 0.0
                
                CustomerGlu.getInstance.openCampaignById(campaign_id: dict?.campaignId ?? "", nudgeConfiguration: nudgeConfiguration)
            }else {
                // If Campaign id is unavailable open wallet condition.
                CustomerGlu.getInstance.openWallet()
            }
        }
        if dict?.secondaryCta?.type == WebViewsKey.open_deeplink{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupLayout() {
        [mainView, cardView, cardBackgroundImageView, imageView, primaryCTAButton, secondaryCTAButton, videoPlayer, closeIconView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let guide = view.safeAreaLayoutGuide
        let screenHeight = UIScreen.main.bounds.height
        let isFull = isFullLayout()
        if isFull {
            cardHeight = screenHeight
            cardBottomMargins = 0
        } else {
            cardHeight = CGFloat(Double(entryPointsData?.mobile.container.height ?? "400") ?? screenHeight * 0.6)
        }
        var constraints: [NSLayoutConstraint] = [
            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            cardView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            
            cardBackgroundImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            cardBackgroundImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            cardBackgroundImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cardBackgroundImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            videoPlayer.topAnchor.constraint(equalTo: cardView.topAnchor),
            videoPlayer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            videoPlayer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            videoPlayer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            
            primaryCTAButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            primaryCTAButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            primaryCTAButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            secondaryCTAButton.topAnchor.constraint(equalTo: primaryCTAButton.bottomAnchor, constant: 12),
            secondaryCTAButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            secondaryCTAButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            secondaryCTAButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            
            closeIconView.widthAnchor.constraint(equalToConstant: 32),
            closeIconView.heightAnchor.constraint(equalToConstant: 32),
            closeIconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            closeIconView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ]
        
        if isFull {
            constraints.append(contentsOf: [
                cardView.topAnchor.constraint(equalTo: guide.topAnchor),
                cardView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
            ])
        } else {
            constraints.append(contentsOf: [
                cardView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: CGFloat(cardBottomMargins)),
                cardView.heightAnchor.constraint(equalToConstant: cardHeight ?? screenHeight)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func registerDismissTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let tapLocation = sender?.location(in: self.view) else { return }

            // If the tap is outside the cardView, dismiss
            if !cardView.frame.contains(tapLocation) {
                self.handleDismiss()
            }
       // self.handleDismiss()
    }
    
    @objc private func handleDismiss() {
        postAnalyticsEvent(event_name: CGConstants.ENTRY_POINT_DISMISS)
        dismissactionglobal = CGDismissAction.UI_BUTTON
        self.dismiss(animated: true, completion: nil)
    }
    
    private func postAnalyticsEvent(event_name: String) {
        var data = entryPointsData?.mobile.content[0];
        CustomerGlu.getInstance.postAnalyticsEventForEntryPoints(event_name: event_name, entry_point_id: data?._id ?? "", entry_point_name: entryPointsData?.name ?? "" , entry_point_container: entryPointsData?.mobile.container?.type ?? "", content_campaign_id: data?.url ?? "", open_container: data?.openLayout ?? CGConstants.FULL_SCREEN_NOTIFICATION, action_c_campaign_id: data?.campaignId ?? "")
    }
    
    private func applyData() {
        guard let content = entryPointsData?.mobile?.content.first else { return }
        
        
        campaignId = content.campaignId
        
        if let opacity = entryPointsData?.mobile?.conditions.backgroundOpacity {
            
            let black = UIColor.black
            let blackTrans = black.withAlphaComponent(CGFloat(opacity))
            self.view.backgroundColor = blackTrans
        }else{
            let black = UIColor.black
            let blackTrans = black.withAlphaComponent(CGFloat(0.5))
            self.view.backgroundColor = blackTrans
        }
        
        
        if let bgColorHex = content.backgroundColor {
            cardView.backgroundColor = UIColor(hex: bgColorHex)
        }
        
        if let bgImage = content.backgroundImage {
            loadImage(from: bgImage, into: cardBackgroundImageView)
        }
        
        if let type = content.type?.uppercased() {
            if type == "LOTTIE" {
                imageView.isHidden = true
                print("Lottie starts download")
                CGFileDownloader.loadFileAsync(url: URL(string: content.url)!) { [weak self] path, error in
                    DispatchQueue.main.async {
                        if(error == nil){
                            print("Lottie starts downloaded")
                            
                            guard let self = self, error == nil, let path = path else { return }
                            
                            //   let decryptedPath = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: path)
                            let animationView = LottieAnimationView(filePath: path)
                            animationView.translatesAutoresizingMaskIntoConstraints = false
                            animationView.contentMode = .scaleAspectFit
                            animationView.loopMode = .loop
                            print("Lottie file path: \(path)")
                            //   print("Lottie dfile path: \(decryptedPath)")
                            print("File exists: \(FileManager.default.fileExists(atPath: path))")
                            animationView.isHidden = false
                            animationView.play()
                            self.cardView.addSubview(animationView)
                            self.cardView.sendSubviewToBack(animationView)
                            
                            
                            
                            // Add constraints
                            NSLayoutConstraint.activate([
                                animationView.topAnchor.constraint(equalTo: self.cardView.topAnchor),
                                animationView.bottomAnchor.constraint(equalTo: self.cardView.bottomAnchor),
                                animationView.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor),
                                animationView.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor)
                            ])
                        }
                    }
                }
            } else if type == "VIDEO" {
                imageView.isHidden = true
                videoPlayer.isHidden = false
                self.cardView.sendSubviewToBack(videoPlayer)
                
                print("Video starts downloading")
                
                if let videoUrl = URL(string: content.url) {
                    loadOrDownloadPIPVideo(from: content.url)
                    
                }
                
            } else {
                
            }
        }
        if let imageUrl = content.url {
            loadImage(from: imageUrl, into: imageView)
        }
        
        if let closeIcon = content.closeIcon {
            loadImage(from: closeIcon, into: closeIconView)
        }
        
        if let btn = content.primaryCta?.button, btn.showButton ?? false {
            
            primaryCTAButton.setTitle(btn.buttonText, for: .normal)
            primaryCTAButton.setTitleColor(UIColor(hex: btn.buttonTextColor ?? "#FFFFFF"), for: .normal)
            primaryCTAButton.backgroundColor = UIColor(hex: btn.buttonColor ?? "#0000FF")
            primaryCTAButton.titleLabel?.font = .systemFont(ofSize: CGFloat(Double(btn.textSize ?? "16") ?? 16))
            primaryCTAButton.layer.cornerRadius = CGFloat(Double(btn.borderRadius ?? "0") ?? 0)
            if let heightStr = btn.height, let height = Double(heightStr) {
                primaryCTAButton.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
            }
            let marginVertical = CGFloat(Double(btn.marginVertical ?? "16") ?? 16)
             let marginHorizontal = CGFloat(Double(btn.marginHorizontal ?? "20") ?? 20)
            NSLayoutConstraint.activate([
                  primaryCTAButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: marginVertical),
                  primaryCTAButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: marginHorizontal),
                  primaryCTAButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -marginHorizontal)
              ])

        } else {
            primaryCTAButton.isHidden = true
        }
        
        if let btn = content.secondaryCta?.button, btn.showButton ?? false  {
            secondaryCTAButton.setTitle(btn.buttonText, for: .normal)
            secondaryCTAButton.setTitleColor(UIColor(hex: btn.buttonTextColor ?? "#FFFFFF"), for: .normal)
            secondaryCTAButton.backgroundColor = UIColor(hex: btn.buttonColor ?? "#0000FF")
            secondaryCTAButton.titleLabel?.font = .systemFont(ofSize: CGFloat(Double(btn.textSize ?? "16") ?? 16))
            secondaryCTAButton.layer.cornerRadius = CGFloat(Double(btn.borderRadius ?? "0") ?? 0)
            if let heightStr = btn.height, let height = Double(heightStr) {
                secondaryCTAButton.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
            }
            let marginVertical = CGFloat(Double(btn.marginVertical ?? "16") ?? 16)
             let marginHorizontal = CGFloat(Double(btn.marginHorizontal ?? "20") ?? 20)
            
        } else {
            secondaryCTAButton.isHidden = true
        }
        
        
    }
    
    
    func getPIPVideoFilePath(for url: String) -> URL? {
        guard let fileName = URL(string: url)?.lastPathComponent else { return nil }
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent("ad_videos").appendingPathComponent(fileName)
    }
    
    func ensurePIPVideoDirectoryExists() {
        let pipDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("ad_videos")
        if !FileManager.default.fileExists(atPath: pipDir.path) {
            try? FileManager.default.createDirectory(at: pipDir, withIntermediateDirectories: true)
        }
    }
    
    func loadOrDownloadPIPVideo(from urlString: String) {
        ensurePIPVideoDirectoryExists()
        
        guard let videoURL = URL(string: urlString),
              let localFileURL = getPIPVideoFilePath(for: urlString) else { return }
        
        if FileManager.default.fileExists(atPath: localFileURL.path) {
            print("Video loaded from cache")
            playVideo(at: localFileURL)
        } else {
            print("Downloading video")
            URLSession.shared.downloadTask(with: videoURL) { tempURL, response, error in
                guard let tempURL = tempURL, error == nil else {
                    print("Video download failed: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    try FileManager.default.moveItem(at: tempURL, to: localFileURL)
                    print("Video saved to \(localFileURL.path)")
                    DispatchQueue.main.async {
                        self.playVideo(at: localFileURL)
                    }
                } catch {
                    print("Failed to save video: \(error)")
                }
            }.resume()
        }
    }
    
    func playVideo(at url: URL) {
        cardBackgroundImageView.isHidden = true
        videoPlayer.isHidden = false
        cardView.sendSubviewToBack(videoPlayer)
        
        let shouldLoop = entryPointsData?.mobile?.conditions?.pip?.loopVideoPIP ?? true
        videoPlayer.setVideoShouldLoop(with: shouldLoop)
        
        if entryPointsData?.mobile?.conditions?.pip?.muteOnDefaultPIP == true {
            videoPlayer.mute()
        }else{
            videoPlayer.unmute()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
            self.videoPlayer.play(with: CustomerGlu.getInstance.getPiPLocalPath(), startTime: CMTime(seconds: 0.0, preferredTimescale: 600))
        })
        
        
        
        
    }
    
    
    
    private func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        
        if url.pathExtension.lowercased() == "svg" {
            loadSVG(from: urlString, into: imageView)
        } else {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = img
                    }
                }
            }
        }
    }
}
